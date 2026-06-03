import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:instagram/core/functions/toast_show.dart';
import 'package:instagram/core/resources/strings_manager.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/core/utility/injector.dart';
import 'package:instagram/domain/entities/registered_user.dart';
import 'package:instagram/presentation/cubit/firebaseAuthCubit/firebase_auth_cubit.dart';
import 'package:instagram/presentation/pages/register/widgets/get_my_user_info.dart';
import 'package:instagram/presentation/pages/register/widgets/register_widgets.dart';
import 'package:instagram/presentation/widgets/global/custom_widgets/custom_elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/presentation/pages/register/sign_up_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SharedPreferences sharePrefs = injector<SharedPreferences>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  RxBool isHeMovedToHome = false.obs;
  ValueNotifier<bool> isToastShowed = ValueNotifier(false);
  ValueNotifier<bool> isUserIdReady = ValueNotifier(true);
  ValueNotifier<bool> validateEmail = ValueNotifier(false);
  ValueNotifier<bool> validatePassword = ValueNotifier(false);

  @override
  dispose() {
    super.dispose();
    isToastShowed.dispose();
    isUserIdReady.dispose();
    validateEmail.dispose();
    validatePassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RegisterWidgets(
      customTextButton: customTextButton(),
      emailController: emailController,
      passwordController: passwordController,
      validateEmail: validateEmail,
      validatePassword: validatePassword,
    );
  }

  Widget customTextButton() {
    return blocBuilder();
  }

  Widget blocBuilder() {
    return ValueListenableBuilder(
      valueListenable: isToastShowed,
      builder: (context, bool isToastShowedValue, child) =>
          BlocListener<FirebaseAuthCubit, FirebaseAuthCubitState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is CubitAuthConfirmed) {
            onAuthConfirmed(state);
          } else if (state is CubitAuthFailed && !isToastShowedValue) {
            isToastShowed.value = true;
            isUserIdReady.value = true;
            ToastShow.toastStateError(state);
          }
        },
        child: loginButton(),
      ),
    );
  }

  Future<void> onAuthConfirmed(CubitAuthConfirmed state) async {
    String userId = state.user.uid;
    isUserIdReady.value = true;
    myPersonalId = userId;
    if (myPersonalId.isNotEmpty) {
      await sharePrefs.setString("myPersonalId", myPersonalId);

      // Check if this Google user already has a Firestore profile
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        // Existing user → go to home
        Get.offAll(GetMyPersonalInfo(myPersonalId: myPersonalId));
      } else {
        // New Google user → go to complete profile (username step)
        Get.offAll(UserNamePage(
          emailController: TextEditingController(text: state.user.email ?? ''),
          passwordController: TextEditingController(text: ''),
          fullNameController:
              TextEditingController(text: state.user.displayName ?? ''),
        ));
      }
    } else {
      ToastShow.toast(StringsManager.somethingWrong.tr);
    }
  }
  
  Widget loginButton() {
    FirebaseAuthCubit authCubit = FirebaseAuthCubit.get(context);

    return ValueListenableBuilder(
      valueListenable: isUserIdReady,
      builder: (context, bool isUserIdReadyValue, child) =>
          ValueListenableBuilder(
        valueListenable: validateEmail,
        builder: (context, bool validateEmailValue, child) =>
            ValueListenableBuilder(
          valueListenable: validatePassword,
          builder: (context, bool validatePasswordValue, child) {
            bool validate = validatePasswordValue && validateEmailValue;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── existing email/password login button ──
                CustomElevatedButton(
                  isItDone: isUserIdReadyValue,
                  nameOfButton: StringsManager.logIn.tr,
                  blueColor: validate,
                  onPressed: () async {
                    if (validate) {
                      isUserIdReady.value = false;
                      isToastShowed.value = false;
                      await authCubit.logIn(RegisteredUser(
                          email: emailController.text,
                          password: passwordController.text));
                    }
                  },
                ),

                // ── ADD: divider ──
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                  ],
                ),
                const SizedBox(height: 15),

                // ── ADD: Google login button ──
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  icon: const Icon(Icons.g_mobiledata_rounded,
                      size: 30, color: Colors.red),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    isUserIdReady.value = false;
                    isToastShowed.value = false;
                    await authCubit.signInWithGooglePressed();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
