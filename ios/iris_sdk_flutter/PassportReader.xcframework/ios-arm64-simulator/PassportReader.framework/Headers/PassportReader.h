#import <UIKit/UIKit.h>

@interface PassportReader : NSObject

- (void)startInWindowScene: (UIWindowScene* _Nonnull) windowScene
                     token: (NSString* _Nonnull) token
                completion: (void (^ _Nonnull)(NSString* _Nonnull givenNames,
                                               NSString* _Nonnull surname,
                                               NSString* _Nonnull dateOfBirth,
                                               NSString* _Nonnull nationality,
                                               NSString* _Nonnull sex,
                                               NSString* _Nonnull documentNumber,
                                               NSString* _Nonnull documentType,
                                               NSString* _Nonnull expiryDate,
                                               NSString* _Nonnull issuingCountry,
                                               NSString* _Nonnull issuer,
                                               NSString* _Nonnull optionalData,
                                               NSString* _Nonnull optionalData2,
                                               NSData* _Nonnull portrait,
                                               NSString* _Nonnull personalNumber,
                                               NSString* _Nonnull placeOfBirth,
                                               BOOL chipAuthentication,
                                               BOOL activeAuthentication,
                                               NSString* _Nonnull protocol,
                                               NSData* _Nonnull face)) completion
                   failure: (void (^ _Nonnull)(NSInteger error)) failure
              cancellation: (void (^ _Nonnull)(void)) cancellation;

- (void)startMRZScanInWindowScene: (UIWindowScene* _Nonnull) windowScene
                         completion: (void (^ _Nonnull)(NSArray* _Nonnull keys)) completion
                            failure: (void (^ _Nonnull)(NSInteger error)) failure
                       cancellation: (void (^ _Nonnull)(void)) cancellation;

- (void)startChipReadInWindowScene: (UIWindowScene* _Nonnull) windowScene
                            keys: (NSArray* _Nonnull) keys
                           completion: (void (^ _Nonnull)(NSString* _Nonnull givenNames,
                                                          NSString* _Nonnull surname,
                                                          NSString* _Nonnull dateOfBirth,
                                                          NSString* _Nonnull nationality,
                                                          NSString* _Nonnull sex,
                                                          NSString* _Nonnull documentNumber,
                                                          NSString* _Nonnull documentType,
                                                          NSString* _Nonnull expiryDate,
                                                          NSString* _Nonnull issuingCountry,
                                                          NSString* _Nonnull issuer,
                                                          NSString* _Nonnull optionalData,
                                                          NSString* _Nonnull optionalData2,
                                                          NSData* _Nonnull portrait,
                                                          NSString* _Nonnull personalNumber,
                                                          NSString* _Nonnull placeOfBirth,
                                                          NSString* _Nonnull signer,
                                                          BOOL passiveAuthentication,
                                                          BOOL chipAuthentication,
                                                          BOOL activeAuthentication,
                                                          NSString* _Nonnull protocol,
                                                          NSData* _Nonnull archive)) completion
                              failure: (void (^ _Nonnull)(NSInteger error)) failure
                         cancellation: (void (^ _Nonnull)(void)) cancellation;

- (void)startFaceVerificationInWindowScene: (UIWindowScene* _Nonnull) windowScene
                             portrait: (NSData* _Nonnull) portrait
                           completion: (void (^ _Nonnull)(NSData* _Nonnull face)) completion
                              failure: (void (^ _Nonnull)(void)) failure
                         cancellation: (void (^ _Nonnull)(void)) cancellation;

- (void)startQRCodeScanInWindowScene: (UIWindowScene* _Nonnull) windowScene
                            completion: (void (^ _Nonnull)(NSString* _Nonnull token)) completion
                          cancellation: (void (^ _Nonnull)(void)) cancellation;

- (NSString* _Nonnull)version;

@end
