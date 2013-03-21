//
//  CustomImageView.m

//

#import "CustomImageView.h"

@implementation CustomImageView
@synthesize isFromGallery=_isFromGallery;
@synthesize isFromCart = _isFromCart;

@synthesize imageObject = _imageObject;



- (void) loadImageFromUrl:(NSURL*)url {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSData * data = [[NSData alloc]initWithContentsOfURL:url];
    UIImage * image = [[UIImage alloc]initWithData:data];
    int x1,y1;
    
    if(_isFromCart)
    {
        y1= (90-image.size.height)/2;
        x1 = (90 - image.size.width)/2;
        [self setFrame:CGRectMake(x1, y1, image.size.width, image.size.height)];
        
    }
    else{
        if(_isFromGallery)
        {  if(image.size.width<200 || image.size.height<150)
            [self setFrame:CGRectMake((430-image.size.width/2)/2,(325-image.size.height/2)/2-2.5,image.size.width/2,image.size.height/2)];
        }
        else{
            y1= (115-image.size.height)/2;
            x1 = (115 - image.size.width)/2;
            [self setFrame:CGRectMake(x1, y1, image.size.width, image.size.height)];
        }
        
    }
    [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
    
    [image release];
    [data release];
    [pool release];
}

- (void) setImage:(UIImage *)image {
    
    [super setImage:image];
    [_indicator stopAnimating];
    [_indicator setHidden:YES];
}

- (void) showImage:(NSURL *)url {
    
    [_indicator setHidden:NO];
    [_indicator startAnimating];
    [NSThread detachNewThreadSelector:@selector(loadImageFromUrl:) toTarget:self withObject:url];
}

- (id) init {
    
    return nil;
}

- (id)initWithUrl:(NSURL *)url frame:(CGRect)frame isFrom:(int)isFromCart{
    
    self = [super init];
    if (self) {
        _isFromCart=isFromCart;
        
        
        [self setClipsToBounds:YES];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.frame = frame;
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if(_isFromCart){
            _indicator.frame = CGRectMake((frame.size.width-30)/2, (frame.size.height-30)/2, 20.0, 20.0);
            
        }else{
            _indicator.frame = CGRectMake((frame.size.width-20)/2, (frame.size.height-20)/2, 20.0, 20.0);
            
        }
        
        [_indicator hidesWhenStopped];
        [_indicator setHidden:YES];
        [self addSubview:_indicator];
        self.contentMode = UIViewContentModeScaleAspectFit;
        [self showImage:url];
    }
    
    return self;
}

- (void)dealloc {
    
    [_indicator release];
    _indicator = nil;
    [_imageObject release];
    self.imageObject = nil;
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
