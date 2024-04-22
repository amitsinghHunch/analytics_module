import 'package:flutter_config_plus/flutter_config_plus.dart';

final String pinpointProjectId = FlutterConfigPlus.get('PINPOINT_PROJECT_ID');
final String cognitoPollId = FlutterConfigPlus.get('COGNITO_POLL_ID');
const String elitelCreatorAccess = 'elite_creator_access';
const String fullCreatorAccess = 'full_creator_access';
const String limitedCreatorAccess = 'limited_creator_access';

final amplifyconfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "analytics": {
        "plugins": {
            "awsPinpointAnalyticsPlugin": {
                "pinpointAnalytics": {
                    "appId": "$pinpointProjectId",
                    "region": "ap-south-1"
                },
                "pinpointTargeting": {
                    "region": "ap-south-1"
                }
            }
        }
    },
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "$cognitoPollId",
                            "Region": "ap-south-1"
                        }
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [],
                        "signupAttributes": [],
                        "passwordProtectionSettings": {
                            "passwordPolicyCharacters": []
                        },
                        "mfaTypes": [],
                        "verificationMechanisms": []
                    }
                },
                "PinpointAnalytics": {
                    "Default": {
                        "AppId": "$pinpointProjectId",
                        "Region": "ap-south-1"
                    }
                },
                "PinpointTargeting": {
                    "Default": {
                        "Region": "ap-south-1"
                    }
                }
            }
        }
    }
}''';
