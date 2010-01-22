package com.floorplanner.blender.file {

	import com.floorplanner.blender.objects.BlendMTFace;
	import com.floorplanner.blender.objects.BlendMFace;
	import com.floorplanner.blender.objects.BlendMVert;
	import com.floorplanner.blender.objects.BlendMesh;
	import com.floorplanner.blender.objects.BlendObject;
	import com.floorplanner.blender.dna.DNAFieldInstance;
	import com.floorplanner.blender.dna.DNAField;
	import com.floorplanner.blender.dna.DNAStruct;
	import com.floorplanner.blender.dna.DNARepository;
	import flash.utils.ByteArray;
	
	/**
	 * @author timknip
	 */
	public class BlendFile {
		
		/**
		 * 
		 */
		public var header:BlendFileHeader;
		
		/**
		 * 
		 */
		public var blocks:Array;
		
		/**
		 * 
		 */
		public var dna:DNARepository;
		
		/**
		 * 
		 */
		public var objects:Array;
		
		private var _blockByPointer:Object;
		
		/**
		 * 
		 */
		public function BlendFile() {
		
		}
		
		/**
		 * 
		 */
		public function getBlockByPointer(pointer:String):BHeadStruct {
			return _blockByPointer[pointer];	
		}

		/**
		 * 
		 */
		public function getBlocksByDNA(dnaIndex:int):Array {
			var result:Array = new Array();
			var block:BHeadStruct;
			
			for each (block in this.blocks) {
				if (block.sdnaIndex == dnaIndex) {
					result.push(block);	
				}
			}
			
			return result;
		}
		
		/**
		 * 
		 */
		public function read(data:ByteArray):void {
			data.position = 0;
			
			this.header = new BlendFileHeader(data);
			
			readBlocks(data);
			readDNA(data);
			
			readObjects(data);
			linkObjectData(data);
		}
		
		/**
		 * Read all block headers
		 */
		private function readBlocks(data:ByteArray):void {
			var block:BHeadStruct = new BHeadStruct(data, this.header.pointerSize, this.header.charSet);
			
			this.blocks = new Array();
			_blockByPointer = new Object();
			
			while (block.code != "ENDB") {
				this.blocks.push(block);
				_blockByPointer[block.pointer] = block;
				data.position += block.size;				
				block = new BHeadStruct(data, this.header.pointerSize, this.header.charSet);
			}
		}
		
		/**
		 * 
		 */
		private function readDNA(data:ByteArray):void {
			var dnaBlock:BHeadStruct = this.sdnaBlock;	
			if (dnaBlock) {
				data.position = dnaBlock.position;
				this.dna = new DNARepository(data, this.header);
			}
		}
		
		/**
		 *
		 */
		private function readCharArray(data:Array):String {
			var s:String = "";
			var i:int;
			for (i = 0; i < data.length; i++) {
				s += String.fromCharCode(data[i]);
			}
			return s;	
		}
		
		/**
		 *
		 */
		private function readMesh(data:ByteArray, block:BHeadStruct, struct:DNAStruct):BlendMesh {
			var mesh:BlendMesh = new BlendMesh();
			var field:DNAField;
			var i:int;
			
			data.position = block.position;
			
			for each (field in struct.fields) {
				var instance:DNAFieldInstance = new DNAFieldInstance(field, this.header.pointerSize);
				var result:Array = instance.read(data);
				var shortName:String = field.shortName;
				
				if (result && result.length) {
					if (field.type == "char" && shortName == "name" && field.isArray) {
						mesh[shortName] = readCharArray(result);
					} else {
						mesh[shortName] = result;
					}
				} else {
					data.position += field.length;
				}
			}
			
			if (mesh.mvert) {
				block = _blockByPointer[mesh.mvert];
				if (block) {
					data.position = block.position;
					for (i = 0; i < block.count; i++) {
						var v:BlendMVert = readType(data, "MVert", BlendMVert) as BlendMVert;
						mesh.vertices.push(v);
					}
				}
			}
			
			if (mesh.mface) {
				block = _blockByPointer[mesh.mface];
				if (block) {
					data.position = block.position;
					for (i = 0; i < block.count; i++) {
						var f:BlendMFace = readType(data, "MFace", BlendMFace) as BlendMFace;
						mesh.faces.push(f);
					}
				}
			}
			
			if (mesh.mtface) {
				block = _blockByPointer[mesh.mtface];
				if (block) {
					data.position = block.position;
					for (i = 0; i < block.count; i++) {
						var mtface:BlendMTFace = readType(data, "MTFace", BlendMTFace) as BlendMTFace;
						mesh.mtfaces.push(mtface);
					}
				}
			}
			
			return mesh;	
		}
		
		/**
		 *
		 */
		private function readType(data:ByteArray, type:String, cls:Class=null):Object {
			var struct:DNAStruct = this.dna.getStructByType(type);
			var field:DNAField;
			var object:Object = cls ? new cls() : new Object();

			if (!struct) {
				return null;
			}
			
			for each (field in struct.fields) {
				var instance:DNAFieldInstance = new DNAFieldInstance(field, this.header.pointerSize);
				var result:Array = instance.read(data);

				if (result && result.length) {
					if (field.type == "char" && field.shortName == "name" && field.isArray) {
						object[field.shortName] = readCharArray(result);
					} else {
						object[field.shortName] = result;
					}
				} else {
					data.position += field.length;
				}
			}

			return object;
		}
		
		/**
		 *
		 */
		private function readObjects(data:ByteArray):void {
			var struct:DNAStruct = this.dna.getStructByType("Object");
			var blocks:Array = struct ? getBlocksByDNA(struct.index) : null;
			var block:BHeadStruct;
			var field:DNAField;
			
			this.objects = new Array();
			
			if (!blocks) {
				return;	
			}
			
			for each (block in blocks) {
				data.position = block.position;
				
				var object:BlendObject = new BlendObject();
				
				for each (field in struct.fields) {
					var instance:DNAFieldInstance = new DNAFieldInstance(field, this.header.pointerSize);
					var result:Array = instance.read(data);
					var shortName:String = field.shortName;
					var skip:Boolean = true;
					
					if (result && result.length) {
						object[shortName] = result;
						skip = false;
					} else if (field.type == "ID") {
						object.id = readType(data, "ID");
						if (object.id && object.id.name) {
							object.name = object.id.name;
							trace(object.name);
						}
						skip = false;
					}
					
					if (shortName == "data") {
						object.dataBlock = _blockByPointer[object[shortName]];	
					}
					
					if (skip) {
						data.position += field.length;
					}
				}
				
				this.objects.push(object);
			}
		}
		
		/**
		 * 
		 */
		private function linkObjectData(data:ByteArray):void {
			var object:BlendObject;
			var struct:DNAStruct;
			var type:String;
			
			for each (object in this.objects) {
				if (object.dataBlock) {
					data.position = object.dataBlock.position;			
					
					struct = this.dna.structs[object.dataBlock.sdnaIndex];
					type = this.dna.types[struct.type];
					
					switch (type) {
						case "Camera":
							break;
						case "Mesh":
							object.mesh = readMesh(data, object.dataBlock, struct);
							break;
						case "Lamp":
							break;
						default:
							trace("Failed to link type " + type + " to " + object.name);
							break;
					}
				}
			}
		}
		
		/**
		 * 
		 */
		public function get sdnaBlock():BHeadStruct {
			var block:BHeadStruct;
			
			for each (block in this.blocks) {
				if (block.code == "DNA1") {
					return block;
				}
			}
			
			return null;
		}
	}
}
