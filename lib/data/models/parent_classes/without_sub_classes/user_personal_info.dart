import 'package:equatable/equatable.dart';
import 'package:instagram/data/models/child_classes/post/story.dart';

// ignore: must_be_immutable
class UserPersonalInfo extends Equatable {
  String bio;
  String email;
  String name;
  String profileImageUrl;
  String userName;
  String gender; // Integrated gender property field token
  dynamic userId;
  List<dynamic> followedPeople;
  List<dynamic> followerPeople;
  List<dynamic> posts;
  List<dynamic> chatsOfGroups;
  String deviceToken;
  List<dynamic> stories;
  List<Story>? storiesInfo;
  List<dynamic> charactersOfName;
  int numberOfNewNotifications;
  int numberOfNewMessages;
  String channelId;
  List<dynamic> lastThreePostUrls;

  UserPersonalInfo({
    required this.followedPeople,
    required this.followerPeople,
    required this.posts,
    required this.chatsOfGroups,
    required this.stories,
    required this.charactersOfName,
    required this.lastThreePostUrls,
    this.storiesInfo,
    this.name = "",
    this.channelId = "",
    this.deviceToken = "",
    this.bio = "",
    this.email = "",
    this.profileImageUrl = "",
    this.userName = "",
    this.gender = "Prefer not to say", // Standard default option
    this.userId = "",
    this.numberOfNewNotifications = 0,
    this.numberOfNewMessages = 0,
  });

  static UserPersonalInfo fromDocSnap(Map<String, dynamic>? snap) {
    return UserPersonalInfo(
      name: snap?["name"] ?? "",
      bio: snap?["bio"] ?? "",
      email: snap?["email"] ?? "",
      profileImageUrl: snap?["profileImageUrl"] ?? "",
      userName: snap?["userName"] ?? "",
      gender: snap?["gender"] ?? "Prefer not to say", // Populates model instance matching map database keys
      userId: snap?["uid"] ?? "",
      followedPeople: snap?["following"] ?? [],
      followerPeople: snap?["followers"] ?? [],
      posts: snap?["posts"] ?? [],
      chatsOfGroups: snap?["chatsOfGroups"] ?? [],
      stories: snap?["stories"] ?? [],
      charactersOfName: snap?["charactersOfName"] ?? [],
      numberOfNewNotifications: snap?["numberOfNewNotifications"] ?? 0,
      numberOfNewMessages: snap?["numberOfNewMessages"] ?? 0,
      deviceToken: snap?["deviceToken"] ?? "",
      channelId: snap?["channelId"] ?? "",
      lastThreePostUrls: snap?["lastThreePostUrls"] ?? [],
    );
  }

  Map<String, dynamic> toMap() => {
        'following': followedPeople,
        'followers': followerPeople,
        'posts': posts,
        'chatsOfGroups': chatsOfGroups,
        'stories': stories,
        'name': name,
        'userName': userName,
        'bio': bio,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'gender': gender, // Serializes parameter field value safely to Firestore payload map data structures
        'charactersOfName': charactersOfName,
        'uid': userId,
        'numberOfNewNotifications': numberOfNewNotifications,
        'numberOfNewMessages': numberOfNewMessages,
        'deviceToken': deviceToken,
        'channelId': channelId,
        'lastThreePostUrls': lastThreePostUrls,
      };

  @override
  List<Object?> get props => [
        bio,
        email,
        name,
        profileImageUrl,
        userName,
        gender, // Included in value comparisons structures definition lists safely
        userId,
        followedPeople,
        followerPeople,
        posts,
        chatsOfGroups,
        stories,
        storiesInfo,
        charactersOfName,
        numberOfNewNotifications,
        numberOfNewMessages,
        deviceToken,
        channelId,
        lastThreePostUrls,
      ];
}