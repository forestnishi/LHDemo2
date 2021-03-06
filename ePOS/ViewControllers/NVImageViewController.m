//
//  NVImageViewController.m
//
//  Created by katayama akihiko on 2021/02/11.
//

#import "NVImageViewController.h"
#import "ePOSAgent.h"
#import "ePOSUserDefault.h"
#import "ePOS2.h"
#import "ePOSViewController.h"

@interface NVImageViewController ()

@end

@implementation NVImageViewController {
    NSArray *imgArray;
    NSArray *label2Array;
    UIImageView *imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    // self = tableView の高さは想定できないので、以下のように実際の高さを取得してみるのがいい。
    CGFloat selfHeight=self.view.bounds.size.height;
    CGFloat selfWidth=self.view.bounds.size.width;
     self.tableView.frame = CGRectMake(158, 0, 500, selfHeight); // 今回は688の想定でSectionなどの設定を考える
    // sectionHeader および sectionFooterの長さはheightForFotterInSectionイベントだけではうまく設定できない。以下を指定すること。
    self.tableView.sectionHeaderHeight = 40.0;
    self.tableView.sectionFooterHeight = 88.0;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 80;
    // tableViewにBackgroundColorを設定できるが、sectionやsectionHeader,sectinoFooterなどを隙間や余りなく並べると見えなくなる
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
    self.rowcnt =1;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    imgArray=@[@"/Documents/Photos/Leo.png",@"img1.JPG",@"img2.JPG",@"img3.JPG",
                     @"img4.JPG",@"img5.JPG",@"img6.JPG",@"img7.JPG"];
    label2Array = @[@"2013/8/23/16:04",@"2013/8/23/16:15",@"2013/8/23/16:47",@"2013/8/23/17:10",
                        @"2013/8/23/1715:",@"2013/8/23/17:21",@"2013/8/23/17:33",@"2013/8/23/17:41"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // ここでSecitonの数を指定するが1を指定するとSeciton0だけが生成される
    return 1;
}

//Table Viewのセルの数を指定
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFotterInSection:(NSInteger)section
{
    return 88;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // まず個々のSectionを描くためにUIViewのオブジェクトを生成する
    UIView *sectionView = [[UIView alloc] init];
    if (section == 0) {
        // UIViewの大きさ(個々のSectionの大きさ)を以下で規定する
        sectionView.frame = CGRectMake(0.0f, 0.0f, 500.0f, 48.0f);
        
        sectionView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        
        // UIView にラベルを追加する。
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 5.0f, 460.0f, 30.0f)];
        // テキストの色を変更したり・・・
        sectionLabel.textColor = [UIColor blackColor];
        // 背景の色を変更したり・・・
        //sectionLabel.backgroundColor = [UIColor whiteColor];
        sectionLabel.text = @"スライドショー用の画像を下のリストに登録します。";
        // シャドウカラーを設定することももちろんできます。
        //sectionLabel.shadowColor = [UIColor blueColor];
        //sectionLabel.shadowOffset = CGSizeMake(0, 0.3);
        // フォント変更ももちろん可能
        sectionLabel.font = [UIFont systemFontOfSize:20];
        // 上で生成したsectionViewに、ラベル描画を付加する
        [sectionView addSubview:sectionLabel];
        
    }
    // sectionViewを戻り値で返すとセクションに反映されます。重要です。
    return sectionView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // sectionの描画と同様にsectionFooterもfooter用のViewを作り、footerViewにラベルやボタンを付加する
    UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 500, 88)];
    footerView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    // Footer上にボタンを作る場合は以下の方法となる。 selectorで示すのは本ViewController上に登録したメソッドを呼び出すようにする
    UIButton* btnWriteNV = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnWriteNV.frame = CGRectMake(310, 50, 100, 30);
    [btnWriteNV setTitle:@"NVに書き込む" forState:UIControlStateNormal];
    [btnWriteNV addTarget:self action:@selector(writeNV) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:btnWriteNV];
    // Footer上にボタンを作る場合は以下の方法となる。 selectorで示すのは本ViewController上に登録したメソッドを呼び出すようにする
    UIButton* btnCloseView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnCloseView.frame = CGRectMake(430, 50, 50, 30);
    [btnCloseView setTitle:@"閉じる" forState:UIControlStateNormal];
    [btnCloseView addTarget:self action:@selector(dismissview) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:btnCloseView];
    // 最後にfooterViewを戻り値として返す
    return footerView;
}

- (void) dismissview
{
    // tableViewを隠すために、dismissViewControllerメソッドを使う
    CGFloat selfHeight=self.tableView.tableFooterView.bounds.size.height;
    CGFloat selfWidth=self.tableView.tableFooterView.bounds.size.width;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) refFile
{
    // tableViewを隠すために、dismissViewControllerメソッドを使う
    CGFloat selfHeight=self.tableView.tableFooterView.bounds.size.height;
    CGFloat selfWidth=self.tableView.tableFooterView.bounds.size.width;
}

- (void) delFile :(NSString *)string
{
    //セルの行番号を取得する　https://qiita.com/sl2/items/6c3241577f0f72850f97
    //特定のセルをリロードする　https://qiita.com/skuromaku/items/95c6b6a862ea5734567e
    //API https://developer.apple.com/documentation/uikit/uitableview/1614935-reloadrowsatindexpaths
    UITableViewCell *cell =
    [self.tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    UILabel *label2 = (UILabel *)[cell viewWithTag:1];
    label2.text = string;
}

- (void) writeNV
{
    if(isDisplayConnected) {
        //ePOSViewController* viewController;
        //[viewController disconnect];
        
    }
}

//各セルの要素を設定する
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // tableView上で利用する各sectionのcellの文字列を指定して、stroyBoard上に置いた各オブジェクトとの紐付けを設定する
    static NSString *CellIdentifier = @"tableCell";
 
    // tableCell の ID で UITableViewCell のインスタンスを生成
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }    
    
    UIImage *img = [UIImage imageNamed:imgArray[indexPath.row]];
    // Tag番号 3 で UIImageView インスタンスの生成
    imageView = (UIImageView *)[cell viewWithTag:3];
    imageView.image = img;
    
    // Tag番号 ２ で UILabel インスタンスの生成  ファイル名
    UILabel *label1 = (UILabel *)[cell viewWithTag:2];
    label1.text = [NSString stringWithFormat:@"No.%d",(int)(indexPath.row+1)];
    
    // Tag番号 1 で UILabel インスタンスの生成　keycode番号
    UILabel *label2 = (UILabel *)[cell viewWithTag:1];
    label2.text = label2Array[indexPath.row];
    
    // 下のCellとの区切りのため線を引いておく
    /*
    UIGraphicsBeginImageContext(cell.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.3, 0.3, 0.3, 1.0);
    CGContextMoveToPoint(context, 0, 78); // 始点
    CGContextAddLineToPoint(context, 360, 78); // 終点
    CGContextStrokePath(context); // 描画
    cell.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();*/
    // せるの背景を指定する
    if( self.rowcnt % 2 ) cell.backgroundColor = [UIColor colorWithRed:0.65 green:0.9 blue:0.65 alpha:1.0];
    else cell.backgroundColor = [UIColor colorWithRed:0.8 green:1.0 blue:0.8 alpha:1.0];
    self.rowcnt ++;
    
    // ファイル参照用ボタンを設ける
    UIButton* btnFileRef = (UIButton *)[cell viewWithTag:4];
    [btnFileRef addTarget:self action:@selector(refFile) forControlEvents:UIControlEventTouchUpInside];
    // ファイル参照削除用ボタンを設ける
    UIButton* btnFileDel = (UIButton *)[cell viewWithTag:5];
    NSString *string = @"maido";
    //[btnFileDel addTarget:self action:@selector(delFile : string) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // レイアウトなどをいろいろいじる
    // …
    CGFloat selfHeight=self.view.bounds.size.height;
    CGFloat selfWidth=self.view.bounds.size.width;
    CGFloat selfTHeight=self.tableView.bounds.size.height;
    CGFloat selfTWidth=self.tableView.bounds.size.width;
    //CGFloat selfFHeight=self.tableView.footerView.bounds.size.height;
    //CGFloat selfFWidth=self.tableView.footerView.bounds.size.width;
    [self.view layoutIfNeeded]; // <- これが重要！
}
@end
