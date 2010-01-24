package {
	import com.floorplanner.blender.dna.DNAField;
	import com.floorplanner.blender.dna.DNARepository;
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
			
			blend.read(new BlenderData());
			
			for each (var struct:DNAStruct in blend.dna.structs) {
				trace(blend.dna.types[struct.type]);
				for each (var field:DNAField in struct.fields) {
					trace ("  " + field.type + " " + field.name);
				}
			}
		}
	}
}
