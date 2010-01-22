package {
	import com.floorplanner.blender.objects.BlendMVert;
	import com.floorplanner.blender.objects.BlendMFace;
	import com.floorplanner.blender.file.BlendFile;
	import com.floorplanner.blender.objects.BlendMesh;
	import com.floorplanner.blender.objects.BlendObject;

	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.geom.Matrix3D;

	[SWF (backgroundColor="#000000")]
	
	/**
	 * @author timknip
	 */
	public class Main extends Sprite {
		
		[Embed (source="/assets/tiefighterlowtriang.blend1", mimeType="application/octet-stream")]
		//[Embed (source="/assets/threecubes.blend", mimeType="application/octet-stream")]
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
			
			blend.read(new BlenderData());
			
			if (blend && blend.objects) {
				drawBlend(this.container.graphics, blend);
			}
		}
		
		private function drawBlend(g:Graphics, blend:BlendFile):void {
			var object:BlendObject;
		
			g.clear();
				
			for each (object in blend.objects) {
				var transform:Matrix3D = new Matrix3D();
				
				if (object.loc) {
					transform.appendTranslation(object.loc[0], object.loc[1], object.loc[2]);	
					transform.appendScale(10, -10, 10);
				}
				
				if (object.mesh) {
					drawMesh(g, object.mesh, transform);
				}
			}
		}
		
		private function drawMesh(g:Graphics, mesh:BlendMesh, transform:Matrix3D):void {
			var face:BlendMFace;
			var v0:BlendMVert;
			var v1:BlendMVert;
			var v2:BlendMVert;
			var i:int;
			var vin:Vector.<Number> = new Vector.<Number>();
			
			for each (face in mesh.faces) {
				v0 = mesh.vertices[face.v1];
				v1 = mesh.vertices[face.v2];
				v2 = mesh.vertices[face.v3];
				
				vin.push(v0.co[0], v0.co[1], v0.co[2]);
				vin.push(v1.co[0], v1.co[1], v1.co[2]);
				vin.push(v2.co[0], v2.co[1], v2.co[2]);
			}
			
			var vout:Vector.<Number> = new Vector.<Number>(vin.length);
			
			transform.transformVectors(vin, vout);
			
			for (i = 0; i < vout.length; i += 9) {
				var x0:Number = vout[i + 0];
				var y0:Number = vout[i + 1];
				var x1:Number = vout[i + 3];
				var y1:Number = vout[i + 4];
				var x2:Number = vout[i + 6];
				var y2:Number = vout[i + 7];	
				
				g.lineStyle(0, 0xff0000);
				g.moveTo(x0, y0);
				g.lineTo(x1, y1);
				g.lineTo(x2, y2);
				g.lineTo(x0, y0);
			}
		}
	}
}
