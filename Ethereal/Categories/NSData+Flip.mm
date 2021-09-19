#import "NSData+Flip.h"

static NSString *CYDHex(NSData *data, bool reverse) {
    if (data == nil)
        return nil;
    
    size_t length([data length]);
    uint8_t bytes[length];
    [data getBytes:bytes];
    
    char string[length * 2 + 1];
    for (size_t i(0); i != length; ++i)
        sprintf(string + i * 2, "%.2x", bytes[reverse ? length - i - 1 : i]);
    
    return [NSString stringWithUTF8String:string];
}

static NSString *HexToDec(NSString *hexValue) {
    if (hexValue == nil)
        return nil;
    
    unsigned long long dec;
    NSScanner *scan = [NSScanner scannerWithString:hexValue];
    if ([scan scanHexLongLong:&dec]) {
        return [NSString stringWithFormat:@"%llu", dec];
    }
    return nil;
}
@implementation NSData (myAdditions)

- (NSString *)stringFromHexData {
    NSString *hexString = CYDHex(self, FALSE);
    return hexString;
}

+ (NSData *)littleEndianHexFromInt:(NSUInteger)inputNumber {
    NSString *hexString = [NSString stringWithFormat:@"%.8lx",(unsigned long)inputNumber];
    return [[NSData dataFromStringHex:hexString] reverse];
}

+ (NSData *)dataFromStringHex:(NSString *)command {
    command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [command length]/2; i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    
    return commandToSend;
}

- (NSData *)reverse {
    return [NSData dataFromStringHex:CYDHex(self, TRUE)];
}

- (NSString *)decimalString {
    NSString *stringData = CYDHex(self, TRUE);
    return HexToDec(stringData);
}

-(NSData *) byteFlipped {
    NSMutableData *newData = [[NSMutableData alloc] init];
    const char *_data = (char *)[self bytes];
    NSUInteger stringLength = [self length];
    NSUInteger x = 0;
    for( x=stringLength-1; x>=0; x-- ){
        char currentByte = _data[x];
        [newData appendBytes:&currentByte length:1];
    }
    return newData;
}
@end
