package {
	import flash.utils.ByteArray;
	import com.floorplanner.blender.dna.DNAField;
	import com.floorplanner.blender.dna.DNAStruct;
	import com.floorplanner.blender.file.BlendFile;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;

	[SWF (backgroundColor="#000000")]
	
	/**
	 * @author timknip
	 */
	public class Main extends Sprite {
		
		//[Embed (source="/assets/tiefighterlowtriang.blend", mimeType="application/octet-stream")]
		[Embed (source="/assets/threecubes.blend", mimeType="application/octet-stream")]
		//[Embed (source="/assets/crystal_cube.blend", mimeType="application/octet-stream")]
		public var BlenderData:Class;
		
		public var container:Sprite;

		public function Main() {
			super();
			
			init();
		}
		
		private function init():void {
		
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW;
			
			this.container = new Sprite();
			addChild(this.container);
			this.container.x = stage.stageWidth * 0.5;
			this.container.y = stage.stageHeight * 0.5;
			
			var blend:BlendFile = new BlendFile();
			var data:ByteArray = new BlenderData();
			
			blend.read(data);
			
			var objs:Array = blend.readType(data, "View3D");
			
			printObject(objs[0]);
			trace(objs);
			// Uncomment the following line to trace out the complete DNA
			//printDNA(blend);
			
			// Blender can have multiple scenes, not sure yet how to get the active scene.
			// So lets simply take the first one.
			if (blend.scenes.length) {
				var scene:Object = blend.scenes[0];
				
		//		buildScene(scene);
			}
		}
		
		/**
		 * Builds a Blender Scene.
		 * 
		 * @param scene
		 */
		private function buildScene(scene:Object):void {

			var obj:Object = scene.base.first;
			
			while (obj) {
				// grab the Blender Object.
				// The Blender Object defines rotation, scale, translation etc.
				var object:Object = obj.object; 
				
				trace("Object name: " + object.id.name + " type: " + object.type + " matrix: " + object.obmat);
				
				// Uncomment following line to show props, guess you'll be using this one a lot :-)
				//printObject(object);
				
				if (object.data) {
					switch (object.type) {
						case 1:	// Mesh
							trace (" -> Mesh: " + object.data.id.name);
							buildMesh(object.data);
							break;
						case 10: // Lamp
							trace (" -> Lamp: " + object.data.id.name);
							break;
						case 11: // Camera
							trace (" -> Camera: " + object.data.id.name);
							break;
						default:
							break;
					}
				}
				
				obj = obj.next;
			}
		}
		
		/**
		 * Builds a Blender Mesh.
		 * 
		 * @param	mesh
		 */
		private function buildMesh(mesh:Object):void {
			var numVertices:int = mesh.totvert;
			var numFaces:int = mesh.totface;
			var i:int;
			
			trace(" -> #verts : " + numVertices);
		
			for (i = 0; i < numVertices; i++) {	
				var v:Object = mesh.mvert[i];
				
				var x:Number = v.co[0];
				var y:Number = v.co[1];
				var z:Number = v.co[2];
				
				trace(" -> -> vertex: " + x + " " + y + " " + z);
			}
			
			trace(" -> #faces : " + numFaces);
			
			for (i = 0; i < numFaces; i++) {	
				var f:Object = mesh.mface[i];
				
				var v1:int = f.v1;
				var v2:int = f.v2;
				var v3:int = f.v3;
				var v4:int = f.v4;
				
				trace(" -> -> indices: " + v1 + " " + v2 + " " + v3 + " " + v4);
				
				if (mesh.mtface) {
					// UV coords are defined
					var tf:Object = mesh.mtface[i];
					
					trace(" -> -> -> uv: " + tf.uv);
				}
			}
		}
		
		/**
		 * Prints out the DNA as contained in the .blend
		 */
		private function printDNA(blend:BlendFile):void {
			var struct:DNAStruct;
			var field:DNAField;
			
			for each (struct in blend.dna.structs) {
				var type:String = blend.dna.types[ struct.type ];
				
				trace(type);
				
				for each (field in struct.fields) {
					trace(" -> " + field.type + " " + field.name);
				}
			}
		}
		
		/**
		 * 
		 */
		private function printObject(object:Object):void {
			for (var key:String in object) {
				trace(key + " : " + object[key]);
			}
		}
	}
}
