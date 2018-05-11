/**
 * Copyright 2017 Kakao Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <KakaoLink/KLKTemplate.h>

NS_ASSUME_NONNULL_BEGIN

@class KLKLinkObject;
@class KLKButtonObject;

/*!
 @class KLKTextTemplate
 @abstract 텍스트형 기본 템플릿 클래스.
 */
@interface KLKTextTemplate : KLKTemplate

/*!
 * @property text
 * @abstract 메시지에 들어갈 텍스트. 최대 200자.
 */
@property (copy, nonatomic) NSString *text;

/*!
 * @property link
 * @abstract 컨텐츠 클릭 시 이동할 링크 정보.
 */
@property (copy, nonatomic) KLKLinkObject *link;

/*!
 * @property buttonTitle
 * @abstract 기본 버튼 타이틀("자세히 보기")을 변경하고 싶을 때 설정.
 */
@property (copy, nonatomic, nullable) NSString *buttonTitle;

/*!
 * @property buttons
 * @abstract 버튼 목록. 버튼 타이틀과 링크를 변경하고 싶을때, 버튼 두개를 사용하고 싶을때 사용. (최대 2개)
 */
@property (copy, nonatomic, nullable) NSArray<KLKButtonObject *> *buttons;

@end

@interface KLKTextTemplate (Constructor)

+ (instancetype)textTemplateWithText:(NSString *)text link:(KLKLinkObject *)link;
- (instancetype)initWithText:(NSString *)text link:(KLKLinkObject *)link;

@end

@interface KLKTextTemplateBuilder : NSObject

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) KLKLinkObject *link;
@property (copy, nonatomic, nullable) NSString *buttonTitle;
@property (copy, nonatomic, nullable) NSMutableArray<KLKButtonObject *> *buttons;

- (void)addButton:(KLKButtonObject *)button;
- (KLKTextTemplate *)build;

@end

@interface KLKTextTemplate (ConstructorWithBuilder)

+ (instancetype)textTemplateWithBuilderBlock:(void (^)(KLKTextTemplateBuilder *textTemplateBuilder))builderBlock;
+ (instancetype)textTemplateWithBuilder:(KLKTextTemplateBuilder *)builder;
- (instancetype)initWithBuilder:(KLKTextTemplateBuilder *)builder;

@end

NS_ASSUME_NONNULL_END
