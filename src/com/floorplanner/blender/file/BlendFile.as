package com.floorplanner.blender.file {

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
		public var scenes:Array;
		
		private var _blockByPointer:Object;
		private var _readPointers:Object;
		private var _pointerData:Object;
		
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
			
			_blockByPointer = new Object();
			_pointerData = new Object();
			_readPointers = new Object();
			
			readBlocks(data);
			readDNA(data);
			
			this.scenes = readType(data, "Scene");
		}
		
		/**
		 * 
		 */
		public function readType(data:ByteArray, type:String):Array {
			var struct:DNAStruct = dna.getStructByType(type);
			var blocks:Array = getBlocksByDNA(struct.index);
			var result:Array = new Array();
			var i:int;
			
			for (i = 0; i < blocks.length; i++) {
				result.push(readBlock(data, blocks[i]));
			}
			
			return result;
		}
		
		/**
		 * Read all block headers
		 */
		private function readBlocks(data:ByteArray):void {
			var block:BHeadStruct = new BHeadStruct(data, this.header.pointerSize, this.header.charSet);
			
			this.blocks = new Array();
			
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
				if (data[i] == 0) break;
				s += String.fromCharCode(data[i]);
			}

			return s;	
		}
		
		/**
		 * 
		 */
		private function readPointer(data:ByteArray):String {
			var s:String = "" + data.readInt();
			if (this.header.pointerSize > 4) {
				s += data.readInt();
			}
			return s;
		}
		
		private function readBlock(data:ByteArray, block:BHeadStruct):Object {
			var struct:DNAStruct = dna.structs[block.sdnaIndex];
			var result:Object = new Object();
			var i:int;
			
			data.position = block.position;
			
			result = block.count > 1 ? new Array(block.count) : new Object();
			
			for (i = 0; i < block.count; i++) {
				if (block.count > 1) {
					result[i] = readStruct(data, struct);	
				} else {
					result = readStruct(data, struct);
				}
			}

			return result;
		}
		
		private function readStruct(data:ByteArray, struct:DNAStruct):Object {
			var field:DNAField;
			var result:Object = new Object();
			
			//trace(indent+dna.types[struct.type]);
			
			for each (field in struct.fields) {
				readField(data, field, result);
			}
			
			return result;
		}
		
		/**
		 * 
		 */
		private function readField(data:ByteArray, field:DNAField, object:Object):void {
			var shortName:String = field.shortName;
			
			if (field.isPointer) {
				var pointer:String = readPointer(data);
				
				if (pointer != "0" && !_readPointers[pointer]) {
					_readPointers[pointer] = 1;
					object[shortName] = _pointerData[pointer] = dereferencePointer(data, pointer);
				} else {
					object[shortName] = _pointerData[pointer];
				}
			} else if (field.isSimpleType) {
				var instance:DNAFieldInstance = new DNAFieldInstance(field, header.pointerSize);
				var value:Array = instance.read(data);
				
				if (field.type == "char" && field.shortName == "name" && field.isArray) {
					object[shortName] = readCharArray(value);	
				} else if (value) {
					object[shortName] = value.length == 1 ? value[0] : value;
				}
			} else {
				var struct:DNAStruct = dna.getStructByType(field.type);
				if (struct) {
					object[shortName] = readStruct(data, struct);
				} else {
					data.position += field.length;
				}
			}
		}
		
		/**
		 * 
		 */
		private function dereferencePointer(data:ByteArray, pointer:String):Object {
			var position:int = data.position;
			var block:BHeadStruct = getBlockByPointer(pointer);
			var result:Object = new Object();
			
			if (block) {
				result = readBlock(data, block);
			}
			
			data.position = position;
			
			return result;
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
