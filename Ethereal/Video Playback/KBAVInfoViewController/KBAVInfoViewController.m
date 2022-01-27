//
//  KBAVInfoViewController.m
//  Ethereal
//
//  Created by kevinbradley on 1/9/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import "KBAVInfoViewController.h"
#import "UIView+AL.h"
#import "UIStackView+Helper.h"
#import "KBSlider.h"
#import "UIImageView+WebCache.h"
#import <MediaAccessibility/MediaAccessibility.h>
#import "KBMoreButton.h"
#import "KBTextPresentationViewController.h"
#import "EXTScope.h"
#import "KBSliderImages.h"
#import "PlayerViewController.h"
#import "KBVideoPlaybackProtocol.h"

@interface KBButton() {
    KBButtonType _buttonType;
    BOOL _selected;
    UIView *_selectedView;
}

@end

@implementation KBButton

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    [super pressesEnded:presses withEvent:event];
    //DLog(@"subtype: %lu type: %lu", event.subtype, event.type);
    UIPress *first = [presses.allObjects firstObject];
    if (first.type == UIPressTypeSelect){
        [self sendActionsForControlEvents:UIControlEventPrimaryActionTriggered];
    }
}

- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state {
    _titleLabel.text = title;
}

- (BOOL)isEnabled {
    return true;
}

- (BOOL)canBecomeFirstResponder {
    return true;
}

- (BOOL)canFocus {
    return true;
}

- (BOOL)canBecomeFocused {
    return true;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    [coordinator addCoordinatedAnimations:^{
        //BOOL contains = (context.focusHeading & UIFocusHeadingDown) != 0;
        DLog(@"direction: %lu", context.focusHeading);
        if (self.isFocused) {
            if (self.focusChanged){
                self.focusChanged(true, context.focusHeading);
            }
            [self setSelected:true];
        } else {
            if (self.focusChanged){
                self.focusChanged(false, context.focusHeading);
            }
            [self setSelected:false];
        }
        
    } completion:^{
        
    }];
    
}


+(instancetype)buttonWithType:(KBButtonType)buttonType {
    KBButton *button = [[KBButton alloc] init];
    if (buttonType == KBButtonTypeText){
        [button _setupLabelView];
    } else if (buttonType == KBButtonTypeImage) {
        [button _setupImageView];
    }
    return button;
}

- (void)_setupSelectedView {
    _selectedView = [[UIView alloc] initForAutoLayout];
    [self addSubview:_selectedView];
    [_selectedView autoPinEdgesToSuperviewEdges];
    _selectedView.alpha = 0;
    _selectedView.backgroundColor = [UIColor darkGrayColor];
}

- (void)_setupLabelView {
    [self _setupSelectedView];
    _titleLabel = [[UILabel alloc] initForAutoLayout];
    [self addSubview:_titleLabel];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleLabel autoCenterInSuperview];
    [_titleLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.8].active = true;
    [_titleLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.8].active = true;
    _selectedView.layer.cornerRadius = 20;
}

- (void)_setupImageView {
    [self _setupSelectedView];
    _buttonImageView = [[UIImageView alloc] initForAutoLayout];
    [self addSubview:_buttonImageView];
    _buttonImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_buttonImageView autoCenterInSuperview];
    [_buttonImageView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.6].active = true;
    [_buttonImageView.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.6].active = true;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (selected){
        _selectedView.alpha = 1.0;
    } else {
        _selectedView.alpha = 0;
    }
}

- (BOOL)selected {
    return _selected;
}

- (void)setButtonType:(KBButtonType)buttonType {
    _buttonType = buttonType;
}

- (KBButtonType)buttonType {
    return _buttonType;
}

@end

@interface KBAVInfoPanelMediaOption() {
    NSString* _displayName;
    NSString* _languageCode;
    AVMediaSelectionOption* _mediaSelectionOption;
    NSInteger _tag;
    BOOL _selected;
}

@end

@implementation KBAVInfoPanelMediaOption

- (KBSubtitleTagType)tag {
    return _tag;
}

- (void)setTag:(KBSubtitleTagType)tag {
    _tag = tag;
}

- (NSString *)description {
    NSString *og = [super description];
    return [NSString stringWithFormat:@"%@ %@ option: %@, selected: %d", og, _displayName, _mediaSelectionOption, _selected];
}

-(BOOL)selected {
    return _selected;
}

-(void)setIsSelected:(BOOL)selected {
    _selected = selected;
}

+(id)optionOff {
    KBAVInfoPanelMediaOption *opt = [[KBAVInfoPanelMediaOption alloc]initWithLanguageCode:nil displayName:@"Off" mediaSelectionOption:nil tag:KBSubtitleTagTypeOff];
    MACaptionAppearanceDisplayType type = MACaptionAppearanceGetDisplayType(kMACaptionAppearanceDomainUser);
    if (type == kMACaptionAppearanceDisplayTypeForcedOnly) {
        [opt setIsSelected:true];
    }
    return opt;
}

+(id)optionAuto {
    KBAVInfoPanelMediaOption *opt = [[KBAVInfoPanelMediaOption alloc]initWithLanguageCode:nil displayName:@"Auto" mediaSelectionOption:nil tag:KBSubtitleTagTypeAuto];
    MACaptionAppearanceDisplayType type = MACaptionAppearanceGetDisplayType(kMACaptionAppearanceDomainUser);
    if (type == kMACaptionAppearanceDisplayTypeAutomatic) {
        [opt setIsSelected:true];
    }
    return opt;
}

- (void)setDisplayName:(NSString *)displayName {
    _displayName = displayName;
}

- (NSString *)displayName {
    return _displayName;
}

- (NSString *)languageCode {
    return _languageCode;
}

- (AVMediaSelectionOption *)mediaSelectionOption {
    return _mediaSelectionOption;
}

- (void)setLanguageCode:(NSString *)languageCode {
    _languageCode = languageCode;
}

- (void)setMediaSelectionOption:(AVMediaSelectionOption *)mediaSelectionOption {
    _mediaSelectionOption = mediaSelectionOption;
}

- (id)initWithLanguageCode:(NSString *_Nullable)code displayName:(NSString *)displayName mediaSelectionOption:(AVMediaSelectionOption * _Nullable)mediaSelectionOption tag:(KBSubtitleTagType)tag {
    self = [super init];
    if (self) {
        _displayName = displayName;
        _languageCode = code;
        _mediaSelectionOption = mediaSelectionOption;
        _tag = tag;
    }
    return self;
}

@end

@interface KBAVInfoPanelCollectionViewTextCell : UICollectionViewCell {

    UIImageView* _checkmarkImageView;
    UILabel* _titleLabel;

}

@property (nonatomic,retain) NSString * title;
-(void)traitCollectionDidChange:(id)arg1 ;
-(void)didUpdateFocusInContext:(id)arg1 withAnimationCoordinator:(id)arg2 ;
@end

@implementation KBAVInfoPanelCollectionViewTextCell

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initForAutoLayout];
        _checkmarkImageView = [[UIImageView alloc] initForAutoLayout];
        [self addSubview:_titleLabel];
        [self addSubview:_checkmarkImageView];
        [_checkmarkImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:27].active = true;
        [_checkmarkImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:3].active = true;
        [_checkmarkImageView autoConstrainToSize:CGSizeMake(34, 29)];
        [_titleLabel.leftAnchor constraintEqualToAnchor:_checkmarkImageView.rightAnchor constant:8].active = true;
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        _checkmarkImageView.image = [KBSliderImages checkmarkImage];//[UIImage systemImageNamed:@"checkmark"];
    } else {
        _checkmarkImageView.image = nil;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _checkmarkImageView.image = nil;
    _titleLabel.text = nil;
}

- (void)traitCollectionDidChange:(id)arg1 {
    [super traitCollectionDidChange:arg1];
}

- (void)didUpdateFocusInContext:(id)arg1 withAnimationCoordinator:(id)arg2 {
    if ([self isFocused]) {
        _titleLabel.textColor = [UIColor whiteColor];
    } else {
        _titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
    [super didUpdateFocusInContext:arg1 withAnimationCoordinator:arg2];
}

@end

@protocol KBAVInfoPanelMediaOptionSelectionDelegate <NSObject>
-(void)mediaOptionCollectionViewController:(id)arg1 didSelectMediaOption:(id)arg2;
@end

@interface KBAVInfoPanelMediaOptionCollectionViewController: UICollectionViewController {
    NSArray *_mediaOptions;
    NSInteger _selectedMediaOptionIndex;
}
@property (nonatomic,retain) NSArray <KBAVInfoPanelMediaOption *>* mediaOptions;
@property (assign,nonatomic) long long selectedMediaOptionIndex;
@property (weak, nonatomic) id <KBAVInfoPanelMediaOptionSelectionDelegate>selectionDelegate;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
-(id)mediaOptionAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation KBAVInfoPanelMediaOptionCollectionViewController

- (void)setSelectedMediaOptionIndex:(long long)selectedMediaOptionIndex {
    _selectedMediaOptionIndex = selectedMediaOptionIndex;
    [self.mediaOptions enumerateObjectsUsingBlock:^(KBAVInfoPanelMediaOption * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == selectedMediaOptionIndex) {
            [obj setIsSelected:true];
        } else {
            [obj setIsSelected:false];
        }
    }];
}

- (long long)selectedMediaOptionIndex {
    return _selectedMediaOptionIndex;
}

- (void)loadView {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal; //CGRectMake(0, 0, 659, 35)
    layout.itemSize = CGSizeMake(80,35);
    layout.minimumLineSpacing = 80;
    UICollectionView *cl = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    cl.translatesAutoresizingMaskIntoConstraints = false;
    self.widthConstraint = [cl.widthAnchor constraintEqualToConstant:470];
    self.widthConstraint.active = true;
    [cl.heightAnchor constraintEqualToConstant:35].active = true;
    self.collectionView = cl;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:KBAVInfoPanelCollectionViewTextCell.class forCellWithReuseIdentifier:@"cell"];
    [self.collectionView autoCenterHorizontallyInSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    //self.widthConstraint.constant = (_mediaOptions.count + 1) * layout.itemSize.width;
}

-  (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KBAVInfoPanelCollectionViewTextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    KBAVInfoPanelMediaOption *opt = [self mediaOptions][indexPath.row];
    cell.title = opt.displayName;
    [cell setSelected:opt.selected];
    return cell;
}

-(NSInteger)collectionView:(id)arg1 numberOfItemsInSection:(NSInteger)arg2 {
    return _mediaOptions.count;
}

- (void)setMediaOptions:(NSArray <KBAVInfoPanelMediaOption *>*)mediaOptions {
    _mediaOptions = mediaOptions;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat newConst = (_mediaOptions.count + 2) * layout.itemSize.width + 70; //70 is just extra padding
    //DLog(@"newconst: %f count: %lu width: %f", newConst, (_mediaOptions.count + 2), layout.itemSize.width);
    self.widthConstraint.constant = newConst;
    [self.collectionView reloadData];
}

- (NSArray <KBAVInfoPanelMediaOption *>*)mediaOptions {
    return _mediaOptions;
}

- (id)mediaOptionAtIndexPath:(NSIndexPath *)indexPath { //this is likely more useful when there are multiple rows of items like for audio
    return _mediaOptions[indexPath.row];
}

@end

@implementation KBAVMetaData
@end

@protocol KBAVInfoPanelSubtitlesDelegate <NSObject>
-(void)viewController:(id)viewController didSelectSubtitleOption:(id)option;
@end

@interface KBAVInfoPanelContentViewController: UIViewController {
    
    BOOL _hasContent;
    UIView* _contentView;
}

@property (nonatomic,readonly) UIView * contentView;
@property (nonatomic,readonly) BOOL hasContent;
-(BOOL)hasContent;
-(UIView *)contentView;
-(void)loadView;

@end

@implementation KBAVInfoPanelContentViewController

- (UIView *)contentView {
    return _contentView;
}

- (BOOL)hasContent {
    return _hasContent;
}

- (void)loadView {
    [super loadView];
}

@end

@interface KBAVInfoPanelSubtitleCollectionViewController: KBAVInfoPanelMediaOptionCollectionViewController

@end

@implementation KBAVInfoPanelSubtitleCollectionViewController

@end

@interface KBAVInfoPanelSubtitlesViewController : KBAVInfoPanelContentViewController <UICollectionViewDelegate> {
    
    KBAVInfoPanelSubtitleCollectionViewController* _subtitleCollectionViewController;
    NSArray* _subtitleOptions;
    NSLayoutConstraint* _subtitleCollectionViewWidthConstraint; //currently unused, will be helpful to implement if we ever need to do manage audio or multiple subtitle tracks
    unsigned long long _selectedSubtitleOptionIndex;

}

@property (assign,nonatomic) id<KBAVInfoPanelSubtitlesDelegate> delegate;
@property (nonatomic, strong) NSArray *subtitleItems;
@property (assign,nonatomic) unsigned long long selectedSubtitleOptionIndex;
-(id)initWithItems:(NSArray *)subtitleItems;
@end

@implementation KBAVInfoPanelSubtitlesViewController

- (id)initWithItems:(NSArray *)subtitleItems {
    self = [super init];
    if (self){
        _subtitleCollectionViewController = [KBAVInfoPanelSubtitleCollectionViewController new];
        _subtitleCollectionViewController.mediaOptions = subtitleItems;
        _subtitleItems = subtitleItems;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view layoutIfNeeded];
    [self addChildViewController:_subtitleCollectionViewController];
    [self.view addSubview:_subtitleCollectionViewController.view];
    [self didMoveToParentViewController:_subtitleCollectionViewController];
    _contentView = self.view;
    _subtitleCollectionViewController.collectionView.delegate = self;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedSubtitleOptionIndex = indexPath.row;
    _subtitleCollectionViewController.selectedMediaOptionIndex = indexPath.row;
    if (_delegate){
        KBAVInfoPanelMediaOption *subtitleItem = self.subtitleItems[indexPath.row];
        [subtitleItem setIsSelected:true];
        [_delegate viewController:self didSelectSubtitleOption:subtitleItem];
        [_subtitleCollectionViewController.collectionView reloadData];
    }
}

@end

@interface KBAVInfoPanelDescriptionViewController : KBAVInfoPanelContentViewController {
    UIStackView *_mainStackView;
    UIImageView *_posterView;
    UIStackView *_detailsStackView;
    UIFocusGuide* _posterFocusGuide;
    UILabel* _titleLabel;
    UILabel* _subtitleLabel;
    UILabel* _durationLabel;
    UILabel* _genreLabel;
    UILabel* _yearLabel;
    UIImageView* _videoResolutionBadge;
    UIImageView* _ccBadge;
    NSLayoutConstraint* _posterViewWidthConstraint;
    NSLayoutConstraint* _posterViewHeightConstraint;
    BOOL _closedCaptioned;
    KBAVMetaData* _metadata;
    NSDate* _creationDate;
    double _duration;
    
}

@property (nonatomic,copy) KBAVMetaData * metadata;
@property (nonatomic,copy) NSDate * creationDate;
@property (assign,nonatomic) double duration;
@property (assign,nonatomic) BOOL closedCaptioned;
@property (assign,nonatomic) long long videoResolution;
@property (assign,nonatomic) long long videoRange;
@property (assign,nonatomic) long long audioFormat;
@property (nonatomic,readonly) BOOL hasContent;
@property (nonatomic) KBMoreButton *summaryView;
@property (readwrite,assign) KBAVInfoStyle infoStyle;
- (UIImageView *)posterView;
@end

@implementation KBAVInfoPanelDescriptionViewController

- (UIImageView *)posterView {
    return _posterView;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    [_posterView.heightAnchor constraintEqualToConstant:_mainStackView.frame.size.height *.08].active = true;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (BOOL)hasContent {
    return (_metadata);
}

- (void)loadView {
    [super loadView];
    _mainStackView = [[UIStackView alloc] initForAutoLayout];
    _mainStackView.axis = UILayoutConstraintAxisHorizontal;
    _mainStackView.distribution = UIStackViewDistributionEqualSpacing; //3
    _mainStackView.alignment = UIStackViewAlignmentCenter;
    _mainStackView.spacing = 35;
    [self.view addSubview:_mainStackView];
    [_mainStackView autoCenterInSuperview];
    _posterView = [[UIImageView alloc] initForAutoLayout];
    _posterView.contentMode = UIViewContentModeScaleAspectFit;
    //[_posterView autoConstrainToSize:CGSizeMake(235, 132)];
    //used to be 235x235
    _posterViewHeightConstraint = [_posterView.heightAnchor constraintLessThanOrEqualToConstant:230];
    _posterViewHeightConstraint.active = true;
    _posterViewWidthConstraint = [_posterView.widthAnchor constraintLessThanOrEqualToConstant:409];
    _posterViewWidthConstraint.active = true;
    //_posterView.backgroundColor = [UIColor redColor];
    [self setupLabels];
    _detailsStackView = [[UIStackView alloc] initForAutoLayout];
    _detailsStackView.axis = UILayoutConstraintAxisVertical;
    _detailsStackView.distribution = UIStackViewDistributionEqualSpacing;
    _detailsStackView.spacing = 8;
    _detailsStackView.alignment = UIStackViewAlignmentTop; //1
    UIStackView *middleStack = [[UIStackView alloc] initForAutoLayout];
    middleStack.axis = UILayoutConstraintAxisHorizontal;
    middleStack.distribution = UIStackViewDistributionEqualSpacing;
    middleStack.spacing = 10;
    //duration | genre | year | CC | HD
    [middleStack setArrangedViews:@[_durationLabel, _genreLabel, _yearLabel, _ccBadge, _videoResolutionBadge]];
    [_detailsStackView setArrangedViews:@[_titleLabel,_subtitleLabel,_summaryView, middleStack]];
    [_mainStackView setArrangedViews:@[_posterView,_detailsStackView]];
    [self populateTitles];
    //[_mainStackView.widthAnchor constraintEqualToConstant:835].active = true;
    _contentView = _mainStackView;
    
}

- (NSString *)durationFormatted {
    return [[KBAVInfoViewController sharedTimeFormatter] stringFromTimeInterval:_metadata.duration];
}

- (void)populateTitles {
    _titleLabel.text = _metadata.title;
    _subtitleLabel.text = _metadata.subtitle;
    _summaryView.text = _metadata.summary;
    _videoResolutionBadge.alpha = _metadata.isHD;
    _ccBadge.alpha = _metadata.hasCC;
    _genreLabel.text = _metadata.genre;
    _yearLabel.text = _metadata.year;
    _durationLabel.text = [self durationFormatted];
    if (_metadata.image) {
        _posterView.image = _metadata.image;
    } else {
        //DLog(@"imageURL %@:", _metadata.imageURL);
        [_posterView sd_setImageWithURL:_metadata.imageURL
                     placeholderImage:[UIImage imageNamed:@"video-icon"]];
    }
}

- (void)setMetadata:(KBAVMetaData *)metadata {
    _metadata = metadata;
    [self populateTitles];
}

- (void)setupLabels {
    _titleLabel = [[UILabel alloc] initForAutoLayout];
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    _subtitleLabel = [[UILabel alloc] initForAutoLayout];
    _subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    _durationLabel = [[UILabel alloc] initForAutoLayout];
    _durationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _durationLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    _yearLabel = [[UILabel alloc] initForAutoLayout];
    _yearLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _yearLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    _genreLabel = [[UILabel alloc] initForAutoLayout];
    _genreLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _genreLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    _videoResolutionBadge = [[UIImageView alloc] initForAutoLayout];
    _videoResolutionBadge.contentMode = UIViewContentModeScaleAspectFit;
    [_videoResolutionBadge autoConstrainToSize:CGSizeMake(38, 22)];
    _videoResolutionBadge.alpha = 0;
    _videoResolutionBadge.image = [KBSliderImages HDImage];
    _ccBadge = [[UIImageView alloc] initForAutoLayout];
    _ccBadge.contentMode = UIViewContentModeScaleAspectFit;
    [_ccBadge autoConstrainToSize:CGSizeMake(38, 22)];
    _ccBadge.alpha = 0;
    _ccBadge.image = [KBSliderImages CCImage];
    _summaryView = [[KBMoreButton alloc] initForAutoLayout];
    _summaryView.labelMargin = 0.0;
    _summaryView.trailingTextFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _summaryView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _summaryView.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    _summaryView.trailingTextColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [_summaryView autoConstrainToSize:CGSizeMake(1113, 100)]; //used to be 154
    _summaryView.focusedScaleFactor = 1.0;
    _summaryView.cornerRadius = 0.0;
    @weakify(self);
    _summaryView.buttonWasPressed = ^(NSString *text) {
        //DLog(@"pressed button with text: %@", text);
        [self_weak_ showViewWithText:text];
    };
    _summaryView.focusableUpdated = ^(BOOL canFocus) {
        //DLog(@"focusable updated");
        [[self_weak_ parentViewController] setNeedsFocusUpdate];
        [[self_weak_ parentViewController] updateFocusIfNeeded];
    };
    if (self.infoStyle == KBAVInfoStyleNew) {
        _titleLabel.textColor = [UIColor whiteColor];
        _genreLabel.textColor = [UIColor whiteColor];
        _yearLabel.textColor = [UIColor whiteColor];
        _durationLabel.textColor = [UIColor whiteColor];
        UIFont *cap2 = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        [_subtitleLabel setFont:cap2];
        [_summaryView setFont:cap2];
        [_summaryView setTrailingTextFont:cap2];
        [_summaryView setTrailingTextColor:[UIColor whiteColor]];
        [_genreLabel setFont:cap2];
        [_yearLabel setFont:cap2];
        [_durationLabel setFont:cap2];
        _posterView.layer.cornerRadius = 20;
        _posterView.layer.masksToBounds = true;
        _posterView.clipsToBounds = true;
    }
    //[_summaryLabel.widthAnchor constraintLessThanOrEqualToConstant:1113].active = true;
    //[_summaryLabel.heightAnchor constraintLessThanOrEqualToConstant:154].active = true;
    //_summaryLabel.numberOfLines = 0;
    //_summaryLabel.lineBreakMode = NSLineBreakByWordWrapping;
}

- (void)showViewWithText:(NSString *)text {
    KBTextPresentationViewController *textPres = [KBTextPresentationViewController new];
    textPres.textValue = text;
    textPres.packageLogo = _posterView.image;
    textPres.textView.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    textPres.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    textPres.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:textPres animated:YES completion:nil];
}

@end

@interface KBAVInfoViewController () <KBAVInfoPanelSubtitlesDelegate> {
    KBAVMetaData *_metadata;
    __weak AVPlayerItem *_playerItem;
    BOOL _observing;
    NSArray *_subtitleData;
    KBAVInfoStyle _infoStyle;
}
@property UIView *visibleView;
@property UIView *divider;
@property NSLayoutConstraint *heightConstraint;
@property NSLayoutConstraint *topConstraint;
@property KBAVInfoPanelDescriptionViewController *descriptionViewController;
@property KBAVInfoPanelSubtitlesViewController *subtitleViewController;
@property UIFocusGuide *tabBarBottomFocusGuide;
@end

#define TOP_PADDING 60.0
#define SIDE_PADDING 90.0

/*
 cy# [player audioTracks]
 @[@{"handler_name":"English","creation_time":"2016-06-05T06:37:30.000000Z","language":"eng"},@{"handler_name":"English","creation_time":"2016-06-05T06:37:30.000000Z","language":"eng"}]
 */

@implementation KBAVInfoViewController

/*
 `(
         {
         "BPS-eng" = 170;
         "DURATION-eng" = "00:21:34.949000000";
         "NUMBER_OF_BYTES-eng" = 27675;
         "NUMBER_OF_FRAMES-eng" = 630;
         "_STATISTICS_TAGS-eng" = "BPS DURATION NUMBER_OF_FRAMES NUMBER_OF_BYTES";
         "_STATISTICS_WRITING_APP-eng" = "mkvmerge v47.0.0 ('Black Flag') 64-bit";
         "_STATISTICS_WRITING_DATE_UTC-eng" = "2020-09-28 01:02:14";
         language = eng;
     }
 )
 */

- (void)setInfoStyle:(KBAVInfoStyle)infoStyle {
    _infoStyle = infoStyle;
}

- (KBAVInfoStyle)infoStyle {
    return _infoStyle;
}


- (void)setSubtitleData:(NSArray *)subtitleData {
    //_subtitleData = subtitleData;
    __block NSMutableArray *_newArray = [NSMutableArray new];
    [subtitleData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KBAVInfoPanelMediaOption *opt = [[KBAVInfoPanelMediaOption alloc] initWithLanguageCode:obj[@"language"] displayName:obj[@"language"] mediaSelectionOption:nil tag:KBSubtitleTagTypeOn];
        @weakify(self)
        opt.selectedBlock = ^(KBAVInfoPanelMediaOption * _Nonnull selected) {
            //self_weak_.pl
            PlayerViewController *ffAVP = (PlayerViewController *)[self_weak_ parentViewController];
            FFAVPlayerController *player = (FFAVPlayerController*)[ffAVP player];
            if ([player respondsToSelector:@selector(switchSubtitleStream:)]){
                [player setEnableBuiltinSubtitleRender:true];
                [player switchSubtitleStream:(int)idx];
            }
            
        };
        [_newArray addObject:opt];
    }];
    _subtitleData = _newArray;
    //do other stuff
}

- (NSArray *)subtitleData {
    return _subtitleData;
}

- (NSArray *)preferredFocusEnvironments {
    if (self.tempTabBar){
        if (self.descriptionViewController.summaryView.canFocus){
            //DLog(@"allowing desc label to focus");
            return @[self.tempTabBar, self.descriptionViewController.summaryView];
        }
        return @[self.tempTabBar];
    } else if (self.infoButton) {
        if (self.descriptionViewController.summaryView.canFocus){
            //DLog(@"allowing desc label to focus");
            return @[self.infoButton, self.descriptionViewController.summaryView];
        }
        return @[self.infoButton];
    }
    return nil;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (playerItem != _playerItem) {
        if (_observing){
            [self removeObserver];
        }
    }
    _playerItem = playerItem;
    if (!_observing){
        [self addObserver];
    }
    [self checkSubtitleOptions];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (self.playbackStatusChanged){
            self.playbackStatusChanged(status);
        }
        if (status == AVPlayerItemStatusReadyToPlay){
            [self checkSubtitleOptions];
            [self refreshMetadata];
        }
    }
}

- (void)refreshMetadata {
    _metadata.isHD = [self isHD];
    [self setMetadata:_metadata];
}

- (void)removeObserver {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    _observing = false;
}

- (void)addObserver {
    [_playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    _observing = true;
}

- (AVPlayerItem *)playerItem {
    return _playerItem;
}

- (void)setMetadata:(KBAVMetaData *)metadata {
    _metadata = metadata;
    _descriptionViewController.metadata = metadata;
}

+ (NSDateComponentsFormatter *)sharedTimeFormatter {
    static dispatch_once_t minOnceToken;
    static NSDateComponentsFormatter *sharedTime = nil;
    if(sharedTime == nil) {
        dispatch_once(&minOnceToken, ^{
            sharedTime = [[NSDateComponentsFormatter alloc] init];
            sharedTime.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
            sharedTime.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute;
        });
    }
    return sharedTime;
}

- (KBAVMetaData *)metadata {
    return _metadata;
}

- (void)setupLegacy {
    _visibleView = [[UIView alloc] initForAutoLayout];
    _visibleView.layer.masksToBounds = true;
    _visibleView.layer.cornerRadius = 27;
    [self.view addSubview:_visibleView];
    _heightConstraint = [_visibleView.heightAnchor constraintEqualToConstant:430];
    _heightConstraint.active = true;
    [_visibleView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:SIDE_PADDING].active = true;
    _topConstraint = [_visibleView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:-510];
    _topConstraint.active = true;
    [_visibleView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-SIDE_PADDING].active = true;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.translatesAutoresizingMaskIntoConstraints = false;
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false;
    [_visibleView addSubview:blurView];
    [blurView autoPinEdgesToSuperviewEdges];
    [_visibleView addSubview:vibrancyEffectView];
    [vibrancyEffectView autoPinEdgesToSuperviewEdges];
    _tempTabBar = [[UITabBar alloc] initForAutoLayout];
    [_visibleView addSubview:_tempTabBar];
    _tempTabBar.itemSpacing = 100;
    _tempTabBar.delegate = self;
    UITabBarItem *tbi = [[UITabBarItem alloc] initWithTitle:@"Info" image:nil tag:0];
    UITabBarItem *tbt = [[UITabBarItem alloc] initWithTitle:@"Subtitles" image:nil tag:1];
    _tempTabBar.items = @[tbi, tbt];
    [_tempTabBar.widthAnchor constraintEqualToAnchor:_visibleView.widthAnchor].active = true;
    [_tempTabBar.leadingAnchor constraintEqualToAnchor:_visibleView.leadingAnchor].active = true;
    [_tempTabBar.trailingAnchor constraintEqualToAnchor:_visibleView.trailingAnchor].active = true;
    [_tempTabBar.topAnchor constraintEqualToAnchor:_visibleView.topAnchor constant:10].active = true;
    _divider = [[UIView alloc] initForAutoLayout];
    [_divider autoConstrainToSize:CGSizeMake(1640, 1)];
    [_visibleView addSubview:_divider];
    [_divider.centerXAnchor constraintEqualToAnchor:_visibleView.centerXAnchor].active = true;
    _divider.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [_divider.topAnchor constraintEqualToAnchor:_tempTabBar.bottomAnchor constant:30].active = true;
    self.view.alpha = 0;
    _tabBarBottomFocusGuide = [[UIFocusGuide alloc] init];
    [self.view addLayoutGuide:_tabBarBottomFocusGuide];
    [_tabBarBottomFocusGuide.topAnchor constraintEqualToAnchor:self.tempTabBar.bottomAnchor].active = true;
    [_tabBarBottomFocusGuide.heightAnchor constraintEqualToConstant:40].active = true;
    [_tabBarBottomFocusGuide.leadingAnchor constraintEqualToAnchor:self.tempTabBar.leadingAnchor].active = true;
    [_tabBarBottomFocusGuide.trailingAnchor constraintEqualToAnchor:self.tempTabBar.trailingAnchor].active = true;
    //_tabBarBottomFocusGuide.preferredFocusEnvironments = @[self.toggleTypeButton];

}

- (void)setupNew {
    //self.infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.infoButton = [KBButton buttonWithType:KBButtonTypeText];
    self.infoButton.translatesAutoresizingMaskIntoConstraints = false;
    [self.infoButton setTitle:@"Info" forState:UIControlStateNormal];
    [self.infoButton.titleLabel setFont:[UIFont boldSystemFontOfSize:24]];
    //[self.infoButton.heightAnchor constraintEqualToConstant:62].active = true;
    [self.infoButton autoConstrainToSize:CGSizeMake(100, 62)];
    [self.view addSubview:self.infoButton];
    [self.infoButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:60].active = true;
    [self.infoButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15].active = true;
    @weakify(self);
    self.infoButton.focusChanged = ^(BOOL focused, UIFocusHeading heading) {
        if (self_weak_.infoFocusChanged){
            self_weak_.infoFocusChanged(focused, heading);
        }
    };
    _visibleView = [[UIView alloc] initForAutoLayout];
    _visibleView.layer.masksToBounds = true;
    _visibleView.layer.cornerRadius = 27;
    [self.view addSubview:_visibleView];
    _heightConstraint = [_visibleView.heightAnchor constraintEqualToConstant:255];
    _heightConstraint.active = true;
    [_visibleView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:SIDE_PADDING+15].active = true;
    _topConstraint = [_visibleView.topAnchor constraintEqualToAnchor:self.infoButton.bottomAnchor constant:30];
    _topConstraint.active = true;
    [_visibleView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-(SIDE_PADDING+15)].active = true;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.translatesAutoresizingMaskIntoConstraints = false;
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false;
    [_visibleView addSubview:blurView];
    [blurView autoPinEdgesToSuperviewEdges];
    [_visibleView addSubview:vibrancyEffectView];
    [vibrancyEffectView autoPinEdgesToSuperviewEdges];
    _tabBarBottomFocusGuide = [[UIFocusGuide alloc] init];
    [self.view addLayoutGuide:_tabBarBottomFocusGuide];
    [_tabBarBottomFocusGuide.topAnchor constraintEqualToAnchor:self.infoButton.bottomAnchor].active = true;
    [_tabBarBottomFocusGuide.heightAnchor constraintEqualToConstant:40].active = true;
    [_tabBarBottomFocusGuide.leadingAnchor constraintEqualToAnchor:self.infoButton.leadingAnchor].active = true;
    [_tabBarBottomFocusGuide.trailingAnchor constraintEqualToAnchor:self.infoButton.trailingAnchor].active = true;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.infoStyle = KBAVInfoStyleNew;
    self.view.backgroundColor = [UIColor clearColor];
    if (self.infoStyle == KBAVInfoStyleLegacy){
        [self setupLegacy];
    } else if (self.infoStyle == KBAVInfoStyleNew) {
        [self setupNew];
    }
}

- (void)updateFocusIfNeeded {
    //LOG_SELF;
    [super updateFocusIfNeeded];
    if (self.descriptionViewController.summaryView.canFocus) {
        //DLog(@"can focus?");
        _tabBarBottomFocusGuide.preferredFocusEnvironments = @[self.descriptionViewController.summaryView];
    }
}

- (void)showView:(UIView *)view withHeight:(CGFloat)height animated:(BOOL)animated {
    if (!animated){
        view.alpha = 1.0;
        self->_heightConstraint.constant = height;
        [self.view layoutIfNeeded];
        return;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->_heightConstraint.constant = height;
        view.alpha = 1.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)changeHeight:(CGFloat)height animated:(BOOL)animated {
    if (!animated){
            self->_heightConstraint.constant = height;
            [self.view layoutIfNeeded];
        return;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->_heightConstraint.constant = height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)attachToView:(KBSlider *)theView inController:(UIViewController *)pvc {
    [self.view layoutIfNeeded];
    [pvc addChildViewController:self];
    UIView *myView = self.view;
    myView.translatesAutoresizingMaskIntoConstraints = false;
    [pvc.view addSubview:myView];
    self.view.accessibilityViewIsModal = true;
    self.view.alpha = 0;
    _visibleView.alpha = 1;
    [self didMoveToParentViewController:pvc];
    [myView.topAnchor constraintEqualToAnchor:theView.bottomAnchor constant:12].active = true;
    [_visibleView.leadingAnchor constraintEqualToAnchor:theView.leadingAnchor].active = true;
    [_visibleView.trailingAnchor constraintEqualToAnchor:theView.trailingAnchor].active = true;
    theView.attachedView = myView;
    [self addDescriptionController];
    [self.parentViewController.view setNeedsFocusUpdate];
    [self.parentViewController.view updateFocusIfNeeded];
    //[self addSubtitleViewController];
}

- (void)showWithCompletion:(void(^_Nullable)(void))block {
    if (self.delegate) {
        [self.delegate willShowAVViewController];
    }
}

- (void)showFromViewController:(UIViewController *)pvc {
    if (self.infoStyle == KBAVInfoStyleNew) {
        return;
    }
    if (self.delegate) {
        [self.delegate willShowAVViewController];
    }
    [self.view layoutIfNeeded];
    [pvc addChildViewController:self];
    [pvc.view addSubview:self.view];
    self.view.accessibilityViewIsModal = true;
    _visibleView.alpha = 0;
    [self didMoveToParentViewController:pvc];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->_topConstraint.constant = TOP_PADDING;
        self.view.alpha = 1;
        self->_visibleView.alpha = 1;
        [self.view layoutIfNeeded];
        
    }
                     completion:^(BOOL finished) {
        [self.parentViewController.view setNeedsFocusUpdate];
        [self.parentViewController.view updateFocusIfNeeded];
        [self addDescriptionController];
        [self addSubtitleViewController];
    }];
}

- (void)closeWithCompletion:(void(^_Nullable)(void))block {
    if (self.infoStyle == KBAVInfoStyleNew) {
        return;
    }
    if (self.delegate) {
        [self.delegate willHideAVViewController];
    }
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->_topConstraint.constant = -510;
        self->_visibleView.alpha = 0;
        self.view.alpha = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        if (block) {
            block();
        }
    }];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];

}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch(item.tag) {
        case 0: //info
            //self.descriptionViewController.view.alpha = 1;
            self.subtitleViewController.view.alpha = 0;
            self.subtitleViewController.view.userInteractionEnabled = false;
            [self showView:self.descriptionViewController.view withHeight:430 animated:true];
            //[self changeHeight:430 animated:true];
            break;
        case 1: //subs
            self.descriptionViewController.view.alpha = 0;
            //self.subtitleViewController.view.alpha = 1;
            self.subtitleViewController.view.userInteractionEnabled = true;
            [self showView:self.subtitleViewController.view withHeight:200 animated:true];
            //[self changeHeight:200 animated:true];
            break;
    }
}

+ (BOOL)areSubtitlesAlwaysOn {
    MACaptionAppearanceDisplayType type = MACaptionAppearanceGetDisplayType(kMACaptionAppearanceDomainUser);
    return type == kMACaptionAppearanceDisplayTypeAlwaysOn;
}

- (NSArray <KBAVInfoPanelMediaOption *> *)subtitleOptions {
    MACaptionAppearanceDisplayType type = MACaptionAppearanceGetDisplayType(kMACaptionAppearanceDomainUser);
    NSMutableArray *opts = [NSMutableArray new];
    AVAsset *asset = [_playerItem asset];
    if (!_playerItem) {
        if (self.subtitleData) {
            KBAVInfoPanelMediaOption *off = [KBAVInfoPanelMediaOption optionOff];
            @weakify(self);
            off.selectedBlock = ^(KBAVInfoPanelMediaOption * _Nonnull selected) {
                NSLog(@"[Ethereal] off selected block??");
                PlayerViewController *ffAVP = (PlayerViewController *)[self_weak_ parentViewController];
                FFAVPlayerController *player = (FFAVPlayerController*)[ffAVP player];
                if ([player respondsToSelector:@selector(switchSubtitleStream:)]){
                    [player setEnableBuiltinSubtitleRender:false];
                }
            };
            [opts addObject:off];
            [opts addObjectsFromArray:self.subtitleData];
            return opts;
        } else {
            return opts;
        }
    }
    [opts addObject:[KBAVInfoPanelMediaOption optionOff]];
    [opts addObject:[KBAVInfoPanelMediaOption optionAuto]];
    AVMediaSelectionGroup *group = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
    if (group) {
        
        AVMediaSelectionOption *opt = [group defaultOption];
        //DLog(@"opt extendedLanguageTag: %@", [opt extendedLanguageTag]);
        //DLog(@"opt displayName: %@", [opt displayName]);
        
        KBAVInfoPanelMediaOption *sub = [[KBAVInfoPanelMediaOption alloc] initWithLanguageCode:[opt extendedLanguageTag] displayName:[opt displayName] mediaSelectionOption:opt tag:2]; //TODO: make tag smarter here
        if (type == kMACaptionAppearanceDisplayTypeAlwaysOn) {
            [sub setIsSelected:true];
        }
        [opts addObject:sub];
    }
    return opts;
}

- (void)addSubtitleViewController {
    if (!_subtitleViewController) {
        _subtitleViewController = [[KBAVInfoPanelSubtitlesViewController alloc] initWithItems:[self subtitleOptions]];
        [self.view layoutIfNeeded];
        [self addChildViewController:_subtitleViewController];
        UIView *subView = _subtitleViewController.view;
        subView.translatesAutoresizingMaskIntoConstraints = false;
        [_visibleView addSubview:subView];
        [subView.topAnchor constraintEqualToAnchor:_divider.bottomAnchor constant:20].active = true;
        [subView.widthAnchor constraintEqualToConstant:1320].active = true;
        [subView.bottomAnchor constraintEqualToAnchor:_visibleView.bottomAnchor constant:0].active = true;
        [subView autoCenterHorizontallyInSuperview];
        subView.userInteractionEnabled = false;
        _subtitleViewController.delegate = self;
        subView.alpha = 0;
    }
  
}

- (void)addDescriptionController {
    if (!_descriptionViewController) {
        _descriptionViewController = [KBAVInfoPanelDescriptionViewController new];
        _descriptionViewController.infoStyle = self.infoStyle;
        [_descriptionViewController setMetadata:_metadata];
        [self.view layoutIfNeeded];
        [self addChildViewController:_descriptionViewController];
        UIView *descView = _descriptionViewController.view;
        descView.translatesAutoresizingMaskIntoConstraints = false;
        [_visibleView addSubview:descView];
        if (self.infoStyle == KBAVInfoStyleLegacy) {
            [descView.topAnchor constraintEqualToAnchor:_divider.bottomAnchor constant:10].active = true;
            [descView.bottomAnchor constraintEqualToAnchor:_visibleView.bottomAnchor constant:0].active = true;
            [descView autoCenterHorizontallyInSuperview];
        } else if (self.infoStyle == KBAVInfoStyleNew) {
            [descView.topAnchor constraintEqualToAnchor:_visibleView.topAnchor constant:30].active = true;
            [descView.bottomAnchor constraintEqualToAnchor:_visibleView.bottomAnchor constant:-30].active = true;
            _descriptionViewLeadingAnchor = [descView.leadingAnchor constraintEqualToAnchor:_visibleView.leadingAnchor constant:800];
            _descriptionViewLeadingAnchor.active = true;
        }
        //[descView.widthAnchor constraintEqualToConstant:1320].active = true;
        
        //DLog(@"desc view: %@", _descriptionViewController.contentView);
        [self setNeedsFocusUpdate];
        
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //DLog(@"desc view: %@", _descriptionViewController.contentView);
}

- (BOOL)isHD {
    if (_playerItem){
        AVAsset *asset = [_playerItem asset];
        CGSize trackSize = CGSizeZero;
        AVAssetTrack *track = [[asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual] firstObject];
        if (track) {
            trackSize = track.naturalSize;
        } else {
            AVPlayerItemTrack *track = [[_playerItem tracks] firstObject]; //TODO make smarter to be certain its video
            //DLog(@"track: %@", track);
            trackSize = [[track assetTrack] naturalSize];
            //trackSize = asset.naturalSize;
        }
        //CGSize trackSize = [track naturalSize];
        //DLog(@"trackSize: %@", NSStringFromCGSize(trackSize));
        return trackSize.width >= 1280;
    }
    if (_metadata){
        return _metadata.isHD;
    }
    return false;
}

- (BOOL)hasClosedCaptions {
    AVAsset *asset = [_playerItem asset];
    AVMediaSelectionGroup *group = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
    return (group);
}

- (BOOL)subtitlesOn {
    AVAsset *asset = [_playerItem asset];
    AVMediaSelectionGroup *group = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
    AVMediaSelection *selection = [_playerItem currentMediaSelection];
    AVMediaSelectionOption *selected = [selection selectedMediaOptionInMediaSelectionGroup:group];
    return (selected);
    //selectedMediaOptionInMediaSelectionGroup
}

- (void)toggleSubtitles:(BOOL)on {
    if (!_playerItem) return;
    AVAsset *asset = [_playerItem asset];
    AVMediaSelectionGroup *group = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
    if (on) {
        AVMediaSelectionOption *opt = [group defaultOption];
        [_playerItem selectMediaOption:opt inMediaSelectionGroup:group];
        MACaptionAppearanceSetDisplayType(kMACaptionAppearanceDomainUser, kMACaptionAppearanceDisplayTypeAlwaysOn);
    } else {
        MACaptionAppearanceSetDisplayType(kMACaptionAppearanceDomainUser, kMACaptionAppearanceDisplayTypeForcedOnly);
        [_playerItem selectMediaOption:nil inMediaSelectionGroup:group];
    }
}

- (void)checkSubtitleOptions {
    MACaptionAppearanceDisplayType type = MACaptionAppearanceGetDisplayType(kMACaptionAppearanceDomainUser);
    switch(type) {
        case kMACaptionAppearanceDisplayTypeForcedOnly:
            break;
            
        case kMACaptionAppearanceDisplayTypeAutomatic:
            break;
            
        case kMACaptionAppearanceDisplayTypeAlwaysOn:
            [self toggleSubtitles:true];
            break;
    }
}

-(void)viewController:(id)viewController didSelectSubtitleOption:(KBAVInfoPanelMediaOption *)option {
    if (option.tag == KBSubtitleTagTypeOff && option.selectedBlock == nil) {
        MACaptionAppearanceSetDisplayType(kMACaptionAppearanceDomainUser, kMACaptionAppearanceDisplayTypeForcedOnly);
        [self toggleSubtitles:false];
        [_subtitleViewController setSelectedSubtitleOptionIndex:0];
    } else if (option.tag == KBSubtitleTagTypeAuto) {
        MACaptionAppearanceSetDisplayType(kMACaptionAppearanceDomainUser, kMACaptionAppearanceDisplayTypeAutomatic);
        [self toggleSubtitles:false];
        [_subtitleViewController setSelectedSubtitleOptionIndex:1];
    } else if (option.mediaSelectionOption != nil) {
        MACaptionAppearanceSetDisplayType(kMACaptionAppearanceDomainUser, kMACaptionAppearanceDisplayTypeAlwaysOn);
        [_subtitleViewController setSelectedSubtitleOptionIndex:2];
        [self toggleSubtitles:true];
    } else if (option.selectedBlock != nil) {
        option.selectedBlock(option);
    }
    [self closeWithCompletion:nil];
}


- (BOOL)shouldDismissView {
    if (self.infoStyle == KBAVInfoStyleNew) return true;
    UIFocusSystem *fs = [UIFocusSystem focusSystemForEnvironment:self];
    Class cls = NSClassFromString(@"UITabBarButton"); //FIXME: this could get flagged
    if (self.infoStyle == KBAVInfoStyleNew) {
        cls = [UIButton class];
    }
    return [[fs focusedItem] isKindOfClass:cls];
}

@end
