package {
	import com.floorplanner.blender.file.BlendFile;

	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.BasicView;

	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	[SWF (backgroundColor="#000000")]
	
	/**
	 * @author timknip
	 */
	public class PapervisionTest extends BasicView {
		
		//[Embed (source="/assets/tiefighterlowtriang.blend", mimeType="application/octet-stream")]
		//[Embed (source="/assets/threecubes.blend", mimeType="application/octet-stream")]
		[Embed (source="/assets/crystal_cube.blend", mimeType="application/octet-stream")]
		public var BlenderFile:Class;
		
		/**
		 * The Blender file
		 */
		public var blend:BlendFile;
		
		/**
		 * 
		 */
		public var blenderScene:DisplayObject3D;
		
		/**
		 * 
		 */
		public function PapervisionTest() {
			super(0, 0, true, false, CameraType.FREE);
			
			init();
		}
		
		/**
		 * 
		 */
		private function init():void {
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW;
			
			// Read the .blend
			this.blend = new BlendFile();
			this.blend.read(new BlenderFile());
			
			if (this.blend.scenes && this.blend.scenes.length) {
				buildScene(this.blend.scenes[0]);
			}
			
			camera.moveForward(980);
			
			startRendering();
		}

		/**
		 * 
		 */
		override protected function onRenderTick(e:Event=null):void {
			if (this.blenderScene) {
				this.blenderScene.rotationY++;
			}
			super.onRenderTick(e);
		}
		
		/**
		 * 
		 */
		private function buildScene(scene:Object):void {
			var obj:Object = scene.base.first;
			
			this.blenderScene = new DisplayObject3D(scene.id.name);
			this.scene.addChild(this.blenderScene);
			
			while (obj) {
				// The Blender Object defines rotation, scale, translation etc.
				var object:Object = obj.object; 
				var matrix:Matrix3D = new Matrix3D(object.obmat);

				matrix.calculateTranspose();
				
				if (object.data) {
					switch (object.type) {
						case 1: // Mesh
							buildMesh(object.data, matrix);
							break;
						case 10: // Lamp
							break;
						case 11: // Camera
							break;
						default:
							break;
					}
				}
				
				// Move on to the next object.
				obj = obj.next;
			}
		}
		
		/**
		 * 
		 */
		private function buildMesh(mesh:Object, matrix:Matrix3D, loadScale:Number=1):void {
			var material:MaterialObject3D;
			var m:TriangleMesh3D = new TriangleMesh3D(material, new Array(), new Array(), mesh.id.name);
			var numVertices:int = mesh.totvert;
			var numFaces:int = mesh.totface;
			var i:int;

			for (i = 0; i < numVertices; i++) {	
				var v:Object = mesh.mvert[i];
				
				var x:Number = v.co[0];
				var y:Number = v.co[1];
				var z:Number = v.co[2];
				
				m.geometry.vertices.push(new Vertex3D(x*loadScale, y*loadScale, z*loadScale));
			}
			
			for (i = 0; i < numFaces; i++) {	
				var f:Object = mesh.mface[i];
				
				var v1:Vertex3D = m.geometry.vertices[f.v1];
				var v2:Vertex3D = m.geometry.vertices[f.v2];
				var v3:Vertex3D = m.geometry.vertices[f.v3];
				var v4:Vertex3D = m.geometry.vertices[f.v4];
				
				var uv0:NumberUV = new NumberUV();
				var uv1:NumberUV = new NumberUV();
				var uv2:NumberUV = new NumberUV();
				var uv3:NumberUV = new NumberUV();
				
				if (mesh.mtface) {
					// Got UVs!
					var tf:Object = mesh.mtface[i];
					var uv:Array = tf.uv;
					
					uv0.u = uv[0];
					uv0.v = uv[1];
					uv1.u = uv[2];
					uv1.v = uv[3];
					uv2.u = uv[4];
					uv2.v = uv[5];
					uv3.u = uv[6];
					uv3.v = uv[7];
				}
				
				material = new ColorMaterial(Math.random() * 0xffffff, 0.7);
				
				var triangle:Triangle3D = new Triangle3D(m, [v3, v2, v1], material, [uv2, uv1, uv0]);
				
				m.geometry.faces.push(triangle);
				
				if (f.v4 > 0) {
					triangle = new Triangle3D(m, [v4, v3, v1], material, [uv3, uv2, uv0]);
					m.geometry.faces.push(triangle);
				}
			}
			
			
			m.geometry.ready = true;
			
			this.blenderScene.addChild(m);
			
			m.transform = matrix;
			m.updateTransform();
		}
	}
}
