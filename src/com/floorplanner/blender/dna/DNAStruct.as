package com.floorplanner.blender.dna {

	/**
	 * @author timknip
	 */
	public class DNAStruct {
		
		/**
		 * 
		 */
		public var index:int;
		
		/**
		 * 
		 */
		public var type:int;
		
		/**
		 * 
		 */
		public var numFields:int;
		
		/**
		 * 
		 */
		public var fields:Array;
		
		/**
		 * 
		 */
		public var length:int;
		
		/**
		 * 
		 */
		public function DNAStruct(type:int, numFields:int) {
			this.type = type;
			this.numFields = numFields;
			this.fields = new Array(numFields);
			this.length = 0;
			this.index = -1;
		}
	}
}
