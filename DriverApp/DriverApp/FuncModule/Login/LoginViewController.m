//
//  LoginViewController.m
//  DriverApp
//
//  Created by lynulzy on 10/22/15.
//  Copyright © 2015 lynulzy. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "Define.h"
@interface LoginViewController ()<UITextFieldDelegate>

#define TAG_USER_NAME_TF            1001
#define TAG_PASSWROD_TF             1002
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginViewController
{
    LoginViewModel *loginVM_;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    loginVM_ = [[LoginViewModel alloc] init];
    loginVM_.relatedController = self;
    __weak typeof(self) weakSelf = self;
    [loginVM_ setBlocksResutlBlock:^(NSInteger type, id processResult) {
        //登录成功返回
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (type == LoginSuccess) {
            [strongSelf dismissViewControllerAnimated:YES completion:nil];
            [strongSelf tipMessage:processResult success:YES];
            return ;
        }
        DDLog(@"登录时调用block错误");
        
    }
                        errorBlock:^(NSInteger type, id errorInfo) {
                            
                            __strong typeof (weakSelf) strongSelf = weakSelf;
                            if (type == LoginErr_Server || type == LoginErr_Local) {
                                [strongSelf tipMessage:errorInfo success:NO];
                            }
                        }
                      failureBlock:^(NSInteger type, id networStatus) {
                          
                      }];
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
#pragma mark - TextField Delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == TAG_USER_NAME_TF) {
        [(UITextField *)[self.view viewWithTag:TAG_PASSWROD_TF] becomeFirstResponder];
    }
    if (textField.tag == TAG_PASSWROD_TF) {
        [self loginButtonClicked:nil];
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField  {
    
}
#pragma mark - User Action
- (IBAction)loginButtonClicked:(id)sender {
    [self.view endEditing:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
    DDLog(@"username- %@   password %@", self.userNameTF.text, self.passwordTF.text);
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (self.userNameTF.text.length < 2 || self.passwordTF.text.length < 2) {
        [self alertMessage:@"请检查帐号和密码！"];
        return;
    }
    [params setObject:self.userNameTF.text forKey:@"loginname"];
    [params setObject:self.passwordTF.text forKey:@"loginpwd"];
    [params setObject:UDID forKey:@"device"];
    [loginVM_ loginRequest:params];
}

@end
