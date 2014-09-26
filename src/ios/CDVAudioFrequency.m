/********* CDVAudioFrequency.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

#import "ToneReceiver.h"

@interface CDVAudioFrequency : CDVPlugin <ToneReceiverProtocol> {
}

@property (strong, nonatomic) ToneReceiver *toneReceiver;
@property (strong) NSString* callbackId;

- (void)start:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;
- (void)didReceiveFrequency:(Float32)frequency;

@end

@implementation CDVAudioFrequency

- (void)start:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;

    UInt32 spectrumResolution = 16384; //16384; //32768; 65536; 131072;
	
    self.toneReceiver = [[ToneReceiver alloc] initWithSpectrumResolution:spectrumResolution];
    self.toneReceiver.delegate = self;

    [self.toneReceiver start];
}

- (void)stop:(CDVInvokedUrlCommand*)command
{
	[self.toneReceiver stop];

	// callback one last time to clear the callback function on JS side
    if (self.callbackId) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:0.0f];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
    self.callbackId = nil;
}

- (void)didReceiveFrequency:(Float32)frequency
{
    // NSString *frequencyString = [NSString stringWithFormat:@"%li Hz", lroundf(frequency)];
    // NSLog(@"Frequency: %@", frequencyString);
    
    NSDictionary* frequencyData = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:frequency] forKey:@"frequency"];

    if (self.callbackId) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:frequencyData];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void)dealloc
{
    [self stop:nil];
}

- (void)onReset
{
    [self stop:nil];
}

@end
