package com.floorplanner.blender.file {

	import flash.utils.Endian;
	import flash.utils.ByteArray;
	
	/**
	 * @author timknip
	 */
	public class BlendFileHeader {
		public static var CHARSET:String = "iso-8859-1";
		
		private static const MAGIC			:String = 'BLENDER';
		private static const ENDIAN_BIG		:String = 'V';
		private static const ENDIAN_LITTLE	:String = 'v';
		private static const POINTERSIZE_4	:String = '_';
		private static const POINTERSIZE_8	:String = '-';
		
		/**
		 * Pointer size, allowed values are 4 and 8.
		 */
		public var pointerSize:int;
		
		/**
		 * Endian. @see flash.utils.Endian
		 */
		public var endian:String;
		
		/**
		 * Charset to use for reading multibytes from the filestream.
		 */
		public var charSet:String;
		
		/**
		 * Blender version.
		 */
		public var version:String;
		
		/**
		 * Constructor.
		 * 
		 * @param data
		 */
		public function BlendFileHeader(data:ByteArray) {
			this.charSet = BlendFileHeader.CHARSET;
			
			data.position = 0;
			
			if (data.readMultiByte(7, this.charSet) != MAGIC) {
				throw new Error("Not a Blender .blend file!");
			}
			
			switch (String.fromCharCode(data.readByte())) {
				case POINTERSIZE_4:
					this.pointerSize = 4;
					break;
				case POINTERSIZE_8:
					this.pointerSize = 8;
					break;
				default:
					throw new Error("Not a Blender .blend file!");
			}
			
			switch (String.fromCharCode(data.readByte())) {
				case ENDIAN_BIG:
					data.endian = this.endian = Endian.BIG_ENDIAN;
					break;
				case ENDIAN_LITTLE:
					data.endian = this.endian = Endian.LITTLE_ENDIAN;
					break;
				default:
					throw new Error("Not a Blender .blend file!");
			}
			
			this.version = data.readMultiByte(3, this.charSet);
		}

		/**
		 * 
		 */
		public function toString():String {
			var s:String = "";
			s += "pointerSize: " + this.pointerSize;
			s += "\nendian: " + this.endian;
			s += "\nversion: " + this.version + "\n";
			return s;
		}
	}
}
