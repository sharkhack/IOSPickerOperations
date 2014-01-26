/**
 * Created by Azer Bulbul on 1/26/14.
 * Copyright (c) 2014 Azer Bulbul. All rights reserved.
 * 
 * USAGE
 * Camera or Cameraroll
 * Picker.getInstance().showImagePicker(onResult as Function,new Rectangle(0,0,this.width,this.height),800.0,600.0);
 * Picker.getInstance().showCamera(onResult as Function,800.0,600.0);
 * 
 * protected function onResult(e:*=null):void{
 * 	if(e == null){
 * 		// not supported code here
 * 	} else if(e == 'CANCEL'){
 * 		// user cancelled code here
 * 	} else if(e is BitmapData){
 * 		// picked image returned here
 * 	}
 * }
 * 
 * 
 * save jpeg bytearray data 
 * 
 * var bd = new bitmapdata(100,100,false,0x000000);
 * var _ba:BytaArray = new ByteArray();
 * _ba = bitmapdata.encode(bd.rect, new JPEGEncoderOptions(100), _ba);
 * 
 * Picker.getInstance().addEventListener(StatusEvent.STATUS, onResult);
 * Picker.getInstance().SaveImage(_ba);
 * 
 * protected function onResult(e:StatusEvent):void{
 * 	trace("event:"+e.code + " - level:"+e.level);
 * 	if(e.level == 'ERROR'){
 * 		//didnt save image...
 * 	} else if(e.level == 'OK'){ 
 * 		//saved ok code here....
 * 	}
 * }
 * */


package com.azer.pickeroperations
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class Picker extends EventDispatcher implements IEventDispatcher
	{
		
		private static var _instance : Picker;
		private var _callback : Function = null;
		private var output:BitmapData = null;
		
		private static var ext:ExtensionContext = null;
		
		
		public function Picker()
		{
			if (!_instance)
			{
				if(ext == null){
					ext = ExtensionContext.createExtensionContext("com.azer.IOSPickerOperations",null);
					
				}
				_instance = this;
			}
		}
		
		public static function getInstance() : Picker
		{
			return _instance ? _instance : new Picker();
		}
		
		/**
		 * if is available Camera or CameraRoll
		 * @param type = 0 : camera or 1: cameraroll
		 * 
		 * */
		public function isAvailable(type:int = 1) : Boolean
		{
			return (type==0) ? ext.call("isAvailableCamera") : ext.call("isAvailablePicker");
		}
		
		public function showImagePicker( callback : Function,  anchor : Rectangle = null, maxw:Number = 0.0, maxh:Number = 0.0 ) : void
		{
			if (!isAvailable(1)) callback(null);
			
			ext.addEventListener( StatusEvent.STATUS, statusPickerHandler);
			_callback = callback;
			
			if (anchor != null) ext.call("showImagePicker", maxw,maxh,anchor);
			else ext.call("showImagePicker",maxw,maxh);
		}
		
		public function showCamera( callback : Function, maxw:Number = 0.0, maxh:Number = 0.0) : void
		{
			if (!isAvailable(0)) callback(null);
			
			ext.addEventListener( StatusEvent.STATUS, statusPickerHandler);
			_callback = callback;
			
			ext.call("showCamera",maxw,maxh);
			
		}
		
		private function statusPickerHandler(e:StatusEvent):void
		{
			var callback:Function = _callback;
			if (e.code == "PICKED")
			{
				if (callback != null)
				{
					_callback = null;
					
					var mediaType:String = e.level;
					if (mediaType == "IMAGE")
					{
						var outputWidth:int = ext.call("getImageWidth") as int;
						var outputHeight:int = ext.call("getImageHeight") as int;
						output = new BitmapData(outputWidth, outputHeight);
						ext.call("getBitmapData", output);
						
						callback(output);
					}
				}
			}
			else if (e.code == "CANCEL")
			{
				if (callback != null)
				{
					_callback = null;
					callback("CANCEL");
				}
			}
			
		}
		
		
		/**
		 * write comressed bytearray to cameraroll
		 * @param bit compressed image bytearray data.
		 * */
		public function SaveImage(bit:ByteArray):void{
			ext.addEventListener( StatusEvent.STATUS, statusHandler);
			ext.call('writeCompressedImageToLibrary',bit);
		}
		
		private function statusHandler(e:StatusEvent):void
		{
			dispatchEvent(e);
		}
		
		
		public function dispose():void{
			ext.removeEventListener( StatusEvent.STATUS, statusHandler);
			ext.removeEventListener( StatusEvent.STATUS, statusPickerHandler);
			try{
				ext.dispose();
			} catch(e:*){}
			ext = null;
			if(output!=null){
				try{output.dispose();} catch(e:*){}
				output = null;
			}
			_instance = null;
		}
		
	}
}