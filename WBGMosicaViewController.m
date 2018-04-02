//
//  WBGMosicaViewController.m
//  FBSnapshotTestCase
//
//  Created by 石磊 on 2018/3/30.
//

#import "WBGMosicaViewController.h"
#import "XScratchView.h"
#import "XRGBTool.h"
#import "UIImage+library.h"
#import "UIView+YYAdd.h"

@interface WBGMosicaViewController ()
@property (nonatomic, strong) XScratchView *scratchView;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, assign) BOOL barsHiddenStatus;
@end

@implementation WBGMosicaViewController


- (instancetype)initWithImage:(UIImage *)image frame:(CGRect )frame {
    self = [super init];
    if (self) {
        self.image = image;
        self.frame = frame;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat WIDTH = self.view.frame.size.width;
    CGFloat HEIGHT = self.view.frame.size.height;

    XScratchView *scratchView = [[XScratchView alloc] initWithFrame:self.frame];
    //    scratchView.mosaicImage = [XRGBTool getFilterMosaicImageWith:[UIImage imageNamed:@"qq.png"]];
    scratchView.surfaceImage = self.image;
    scratchView.mosaicImage = [XRGBTool getMosaicImageWith:self.image level:0];
    __weak typeof(self)weakSelf = self;
    scratchView.drawingCallback = ^(BOOL isDrawing) {
        [weakSelf hiddenTopAndBottomBar:isDrawing animation:YES];
    };
    scratchView.drawingDidTap = ^(void) {
        [weakSelf hiddenTopAndBottomBar:!weakSelf.barsHiddenStatus animation:YES];
    };
    _scratchView = scratchView;
    [self.view addSubview:scratchView];

    UIView *toolView = [[UIView alloc] init];
    toolView.frame = CGRectMake(0, HEIGHT - 49, WIDTH, 49);
//    toolView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    toolView.backgroundColor = [UIColor colorWithRed:22/255.0 green:25/255.0 blue:26/255.0 alpha:0.88];
    [self.view addSubview:toolView];
    _toolView = toolView;

    CGFloat btnW = WIDTH / 3.0;
    NSArray *arr = @[@"返回",@"撤销",@"完成"];
    NSArray *images = @[@"clip_close",@"icon_sck_cx_a",@"clip_ok"];
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    for (int i = 0; i < arr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnW * i, 0, btnW, 49);
        btn.tag = 100 + i;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.accessibilityLabel = arr[i];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:btn];
        
        if (i == 1) {
            [btn setTitle:arr[i] forState:UIControlStateNormal];
        } else {
            [btn setImage:[UIImage my_imageNamed:images[i] inBundle:classBundle] forState:UIControlStateNormal];
            if (i == 0) {
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 30);
            } else {
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
            }
        }
    }
}

- (void)buttonAction:(UIButton *)btn {
    switch (btn.tag) {
        case 100:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 101:
            [_scratchView recover];
            break;
        case 102:
        {
            __weak typeof(self) weakSelf = self;
            UIGraphicsBeginImageContextWithOptions(weakSelf.scratchView.frame.size, NO, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [weakSelf.scratchView.layer renderInContext:context];
            UIImage *deadledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            if (weakSelf.mosicaCallback) {
                weakSelf.mosicaCallback(deadledImage);
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)hiddenTopAndBottomBar:(BOOL)isHide animation:(BOOL)animation {
    
    [UIView animateWithDuration:animation ? .25f : 0.f delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:isHide ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveEaseIn animations:^{
        if (isHide) {
            self.toolView.top = [UIScreen mainScreen].bounds.size.height;
        } else {
            self.toolView.top = [UIScreen mainScreen].bounds.size.height-49.f;
        }
        self.barsHiddenStatus = isHide;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
