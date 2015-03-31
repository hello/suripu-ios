## NAPickerView

Custom PickerView

## Instalation
NAPickerView can be installed via CocoaPods.
```
pod 'NAPickerView'
```
or simply download and import NASources/*.{h,.m} in your project manually.

## ScreenShot
![image](https://raw.github.com/nghialv/NAPickerView/master/screenshot2.png)

![image](https://raw.github.com/nghialv/NAPickerView/master/screenshot.png)

## Usage

### Example 1: default picker
```
    // create item array
    items = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30;  i++) {
        [items addObject:[NSString stringWithFormat:@"%d", i]];
    }
    // create NAPickerView
    NAPickerView *pickerView = [[NAPickerView alloc] initWithFrame:CGRectMake(40.f, 10.f, 100.f, 200.f)
                                                          andItems:items
                                                       andDelegate:self];
    [pickerView setIndex:5];        // init index
    [self.view addSubview:pickerView];
```

### Example 2 : more settings for picker
```
    items2 = @[@"Naruto", @"Kakashi", @"Sakura", @"Sasuke", @"Choji"];
    NAPickerView *pickerView2 = [[NAPickerView alloc] initWithFrame:CGRectMake(180.f, 10.f, 100.f, 200.f)
                                                          andItems:items2
                                                       andDelegate:self];
    [pickerView2 setIndex:3];                             // set init value
    pickerView2.backgroundColor = [UIColor blackColor];   // set picker background color
    pickerView2.cornerRadius = 8.f;                       // set picker corner radius
    pickerView2.borderColor = [UIColor blueColor];        // set border color
    pickerView2.borderWidth = 3.f;                        // set border width
    // configure cell by block
    pickerView2.configureBlock = ^(NALabelCell *cell, NSString *item) {
        cell.textView.textAlignment = UITextAlignmentCenter;
        cell.textView.font = [UIFont systemFontOfSize:20];
        cell.textView.backgroundColor = [UIColor clearColor];
        cell.textView.textColor = [UIColor grayColor];
        [cell.textView setText:item];
    };
    // congirure cell when highlight by block
    pickerView2.highlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor blueColor];
    };
    // congirure cell when unhighlight by block
    pickerView2.unhighlightBlock = ^(NALabelCell *cell) {
        cell.textView.textColor = [UIColor grayColor];
    };
    [self.view addSubview:pickerView2];
```

### Example 3 : custom the cell of picker. Create the cell with an imageview and a label by following code
```
    // create item array
    items3 = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i++) {
        NSString *title = [NSString stringWithFormat:@"Item %d", i];
        NSArray *obj = @[title, @"image.png"];      // set title and image file name
        [items3 addObject:obj];
    }
    // create NAPickerView
    NAPickerView *pickerView3 = [[NAPickerView alloc] initWithFrame:CGRectMake(40.f, 230.f, 250.f, 200.f)
                                                           andItems:items3
                                                   andCellClassName:@"NACustomCell"
                                                        andDelegate:self];
    [pickerView3 setIndex:3];
    pickerView3.backgroundColor = [UIColor blackColor];
    pickerView3.cornerRadius = 8.f;
    pickerView3.borderColor = [UIColor colorWithRed:0.f green:0.5f blue:0.5f alpha:1.f];
    pickerView3.borderWidth = 3.f;
    pickerView3.configureBlock = ^(NACustomCell *cell, NSArray *item) {
        NSString *title = (NSString *)[item objectAtIndex:0];
        NSString *imageName = (NSString *)[item objectAtIndex:1];
        [cell.avatar setImage:[UIImage imageNamed:imageName]];
        [cell.label setText:title];
    };
    pickerView3.highlightBlock = ^(NACustomCell *cell) {
        cell.label.textColor = [UIColor blueColor];
        cell.avatar.alpha = 1.0;
    };
    pickerView3.unhighlightBlock = ^(NACustomCell *cell) {
        cell.label.textColor = [UIColor grayColor];
        cell.avatar.alpha = 0.5f;
    };
    [self.view addSubview:pickerView3];
```

### Properties
