//
//  NativeExpressAdViewController.m
//  GDTMobApp
//
//  Created by michaelxing on 2017/4/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "NativeExpressVideoAdViewController.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "GDTAppDelegate.h"

@interface NativeExpressVideoAdViewController ()<GDTNativeExpressAdDelegete,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *expressAdViews;

@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;

@property (weak, nonatomic) IBOutlet UILabel *widthLabel;
@property (weak, nonatomic) IBOutlet UISlider *widthSlider;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UISlider *heightSlider;
@property (weak, nonatomic) IBOutlet UISlider *adCountSlider;
@property (weak, nonatomic) IBOutlet UILabel *adCountLabel;
@property (weak, nonatomic) IBOutlet UITextField *placementIdTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISwitch *videoMutedSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *videoAutoPlaySwitch;

@end

@implementation NativeExpressVideoAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    //默认值
    self.widthSlider.value = [UIScreen mainScreen].bounds.size.width;
    self.heightSlider.value = 50;
    self.adCountSlider.value = 3;
    
    self.widthLabel.text = [NSString stringWithFormat:@"宽：%@", @(self.widthSlider.value)];
    self.heightLabel.text = [NSString stringWithFormat:@"高：%@", @(self.heightSlider.value)];
    self.adCountLabel.text = [NSString stringWithFormat:@"count:%@", @(self.adCountSlider.value)];
    
    //一次拉取5条广告
    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppkey:kGDTMobSDKAppId
                                                          placementId:self.placementIdTextField.text
                                                               adSize:CGSizeMake(self.widthSlider.value, self.heightSlider.value)];
    self.nativeExpressAd.delegate = self;
    self.nativeExpressAd.videoAutoPlayOnWWAN = self.videoAutoPlaySwitch.on;
    self.nativeExpressAd.videoMuted = self.videoMutedSwitch.on;
    [self.nativeExpressAd loadAd:(int)self.adCountSlider.value];
    
    [self.widthSlider addTarget:self action:@selector(sliderPositionWChanged) forControlEvents:UIControlEventValueChanged];
    [self.heightSlider addTarget:self action:@selector(sliderPositionHChanged) forControlEvents:UIControlEventValueChanged];
    [self.adCountSlider addTarget:self action:@selector(sliderPositionCountChanged) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"nativeexpresscell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"splitnativeexpresscell"];
}

- (void)dealloc
{
    NSLog(@"%@ dealloc", [self class]);
}

- (IBAction)refreshButton:(id)sender {
    
    //重新拉取5条广告
    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppkey:kGDTMobSDKAppId
                                                          placementId:self.placementIdTextField.text
                                                               adSize:CGSizeMake(self.widthSlider.value, self.heightSlider.value)];
    self.nativeExpressAd.delegate = self;
    self.nativeExpressAd.videoAutoPlayOnWWAN = self.videoAutoPlaySwitch.on;
    self.nativeExpressAd.videoMuted = self.videoMutedSwitch.on;
    
    [self.nativeExpressAd loadAd:(int)self.adCountSlider.value];
}

- (void)sliderPositionWChanged {
    
    self.widthLabel.text = [NSString stringWithFormat:@"宽：%.0f",self.widthSlider.value];
}

- (void)sliderPositionHChanged {
    
    self.heightLabel.text = [NSString stringWithFormat:@"高：%.0f",self.heightSlider.value];

}

- (void)sliderPositionCountChanged {
    self.adCountLabel.text = [NSString stringWithFormat:@"count:%d",(int)self.adCountSlider.value];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views
{
    [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GDTNativeExpressAdView *adView = (GDTNativeExpressAdView *)obj;
        [adView removeFromSuperview];
    }];
    
    self.expressAdViews = [NSArray arrayWithArray:views];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    //vc = [self navigationController];
#pragma clang diagnostic pop
    
    if (self.expressAdViews.count) {
        [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
//            expressView.frame = CGRectMake(0, 0, self.positionW.value, self.positionH.value);
            expressView.controller = rootViewController;
            
            [expressView render];
 
        }];
        
    }
    
    [self.tableView reloadData];
   
}

/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView
{
}

/**
 * 拉取原生模板广告失败
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error
{
    NSLog(@"Express Ad Load Fail : %@",error);
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView
{
    [self.tableView reloadData];
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView
{
    
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView
{
    NSLog(@"--------%s-------",__FUNCTION__);
//    if ([nativeExpressAdView superview]) {
//        [nativeExpressAdView removeFromSuperview];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        UIView *view = [self.expressAdViews objectAtIndex:indexPath.row / 2];
        return view.bounds.size.height;
    }
    else {
        return 44;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.expressAdViews.count * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row % 2 == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"nativeexpresscell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *subView = (UIView *)[cell.contentView viewWithTag:1000];
        if ([subView superview]) {
            [subView removeFromSuperview];
        }
        UIView *view = [self.expressAdViews objectAtIndex:indexPath.row / 2];
        view.tag = 1000;
        [cell.contentView addSubview:view];
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"splitnativeexpresscell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor grayColor];
    }
    
    return cell;
    
}





@end
