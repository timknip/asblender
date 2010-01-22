package com.floorplanner.blender.file {

	import flash.utils.ByteArray;
	/**
	 * A BHeadStruct is the Blender internal's name of a blend-file-header.
	 * It contains information on how to parse the next data-section.
	 * 
	 * @author timknip
	 */
	public class BHeadStruct {

		/**
		 * 
		 */
		public var code:String;
		
		/**
		 * 
		 */
		public var size:int;
		
		/**
		 * 
		 */
		public var sdnaIndex:int;
		
		/**
		 * 
		 */
		public var count:int;
		
		/**
		 * 
		 */
		public var position:int;
		
		/**
		 * 
		 */
		public var pointer:String;
		
		/**
		 * 
		 */	
		public function BHeadStruct(data:ByteArray, pointerSize:int=4, charSet:String="iso-8859-1") {
			this.code = data.readMultiByte(4, charSet);
			this.size = data.readInt();
			this.pointer = "" + data.readInt();
			if (pointerSize != 4) {
				this.pointer += "" + data.readInt();
			}
			this.sdnaIndex = data.readInt();
			this.count = data.readInt();
			this.position = data.position;
		}
	}
}
