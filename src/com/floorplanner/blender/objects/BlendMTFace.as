package com.floorplanner.blender.objects {

	/**
	 * @author timknip
	 */
	public dynamic class BlendMTFace {
		
		/**
		 * 
		 */
		public var uv:Array;
		
		/**
		 * 
		 */
		public var unwrap:int;
		
		/**
		 * 
		 */
		public var transp:int;
		
		/**
		 * 
		 */
		public var mode:int;
		
		/**
		 * 
		 */
		public var flag:int;
		
		/**
		 * 
		 */
		public var tile:int;
		
		/**
		 * 
		 */
		public function BlendMTFace() {
			
		}
		
		/**
		 * 
		 */
		public function toString():String {
			return "" + uv + " unwrap: " + unwrap + " transp: " + transp + " mode: " + mode + " flag: " + flag + " tile: " + tile; 
		}
	}
}
