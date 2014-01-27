IOSPickerOperations NativeExtension
===============

Air Native Extension for mobile camera and gallery features (IOS picker and save gallery)

- This is an Air native extension that allows you to display native UI to pick images from the gallery or take a picture with the camera on iOS.

- Save compressed BitmapData (byte array) to camera roll (iOS photo library)

- This ane fixes camera and cameraroll (pick or save) memory leak problem.

It has been developed by Azer Bulbul


USAGE

  ```actionscript
//Camera or Cameraroll
  Picker.getInstance().showImagePicker(onResult as Function,new Rectangle(0,0,this.width,this.height),800.0,600.0);
  Picker.getInstance().showCamera(onResult as Function,800.0,600.0);
  
  protected function onResult(e:*=null):void{
  	if(e == null){
  		// not supported code here
  	} else if(e == 'CANCEL'){
  		// user cancelled code here
  	} else if(e is BitmapData){
  		// picked image returned here
  	}
  }
  
  
  //save jpeg bytearray data 
  
  var bd = new bitmapdata(100,100,false,0x000000);
  var _ba:BytaArray = new ByteArray();
  _ba = bitmapdata.encode(bd.rect, new JPEGEncoderOptions(100), _ba);
  
  Picker.getInstance().addEventListener(StatusEvent.STATUS, onResult);
  Picker.getInstance().SaveImage(_ba);
  
  protected function onResult(e:StatusEvent):void{
  	trace("event:"+e.code + " - level:"+e.level);
  	if(e.level == 'ERROR'){
  		//didnt save image...
  	} else if(e.level == 'OK'){ 
  		//saved ok code here....
  	}
  }
