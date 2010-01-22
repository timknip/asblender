package com.floorplanner.blender.objects {

	/**
	 * @author timknip
	 */
	public dynamic class BlendMesh {
		
		/**
		 * Vertices.
		 */
		public var vertices:Array;
		
		/**
		 * Faces. 
		 */
		public var faces:Array;
		
		/**
		 * Texture faces.
		 */
		public var mtfaces:Array;
		
		/**
		 * 
		 */
		public function BlendMesh() {
			this.vertices = new Array();
			this.faces = new Array();
			this.mtfaces = new Array();
		}
	}
}
