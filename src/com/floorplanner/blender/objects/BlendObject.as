package com.floorplanner.blender.objects {

	import com.floorplanner.blender.file.BHeadStruct;
	/**
	 * @author timknip
	 */
	public dynamic class BlendObject {
		
		/**
		 * 
		 */
		public var id:Object;
		
		/**
		 * 
		 */
		public var name:String;
		
		/**
		 * 
		 */
		public var loc:Array;
		
		/**
		 * 
		 */
		public var dloc:Array;
		
		/**
		 * 
		 */
		public var rot:Array;
		
		/**
		 * 
		 */
		public var dataBlock:BHeadStruct;
		
		/**
		 * 
		 */
		public var mesh:BlendMesh;
		
		/**
		 * 
		 */
		public function BlendObject() {

		}
	}
}
