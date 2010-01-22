package com.floorplanner.blender.dna {

	import flash.errors.IllegalOperationError;
	import com.floorplanner.blender.file.BlendFileHeader;
	import flash.utils.ByteArray;
	
	/**
	 * @author timknip
	 */
	public class DNARepository {
		
		/**
		 * 
		 */
		public var header:BlendFileHeader;
		
		/**
		 * 
		 */
		public var names:Array;
		
		/**
		 * 
		 */
		public var types:Array;
		
		/**
		 * 
		 */
		public var lengths:Array;
		
		/**
		 * 
		 */
		public var structs:Array;
		
		private var _structByType:Object;
		
		/**
		 * 
		 */
		public function DNARepository(data:ByteArray, header:BlendFileHeader) {
			this.header = header;
			if (data) {
				read(data);
			}
		}

		/**
		 * 
		 */
		public function getStructByType(type:String):DNAStruct {
			return _structByType[type];
		}

		/**
		 * 
		 */
		public function read(data:ByteArray):void {
			
			if (data.readMultiByte(4, header.charSet) != "SDNA") {
				throw new IllegalOperationError("Not a DNA fileblock!");
			}
			
			if (data.readMultiByte(4, header.charSet) != "NAME") {
				throw new IllegalOperationError("Not a DNA fileblock!");
			}
			
			readNames(data);
			
			byteAlign(data, 4);
			if (data.readMultiByte(4, header.charSet) != "TYPE") {
				throw new IllegalOperationError("Not a DNA fileblock!");
			}	
			
			readTypes(data);
			
			byteAlign(data, 4);
			if (data.readMultiByte(4, header.charSet) != "STRC") {
				throw new IllegalOperationError("Invalid Blender file!");
			}
			
			readStructs(data);
		}
		
		/**
		 * 
		 */
		private function byteAlign(data:ByteArray, count:int=4):void {
			data.position = Math.ceil(data.position / count) * count;
		}
		
		/**
		 * 
		 */
		private function readNames(data:ByteArray):void {
			var count:int = data.readInt();
			var i:int;
			
			this.names = new Array(count);
			
			for (i = 0; i < count; i++) {
				this.names[i] = readString(data);
			}
		}
		
		/**
		 * 
		 */
		private function readStructs(data:ByteArray):void {
			var count:int = data.readInt();
			var i:int, j:int;
			
			this.structs = new Array(count);
			
			_structByType = new Object();
			
			for (i = 0; i < count; i++) {
				var struct:DNAStruct = new DNAStruct(data.readShort(), data.readShort());
				
				for (j = 0; j < struct.numFields; j++) {
					var field:DNAField = new DNAField(data.readShort(), data.readShort());
					
					field.name = this.names[field.nameIndex];
					field.type = this.types[field.typeIndex];
					field.length = this.lengths[field.typeIndex];
					
					struct.fields[j] = field;

					struct.length += field.length;
				}
				
				struct.index = i;
				
				this.structs[i] = struct;
				
				_structByType[this.types[struct.type]] = struct;
			}
		}
		
		/**
		 * 
		 */
		private function readTypes(data:ByteArray):void {
			var count:int = data.readInt();
			var i:int;
			
			this.types = new Array(count);
			this.lengths = new Array(count);
			
			for (i = 0; i < count; i++) {
				this.types[i] = readString(data);	
			}
			
			byteAlign(data, 4);
			
			if (data.readMultiByte(4, header.charSet) != "TLEN") {
				throw new Error("Invalid Blender file!");
			}
			
			for (i = 0; i < count; i++) {
				this.lengths[i] = data.readShort();
			}
		}
		
		/**
		 * 
		 */
		private function readString(data:ByteArray):String {
			var s:String = "";
			var c:int = data.readByte();
			while (c) {
				s += String.fromCharCode(c);
				c = data.readByte();
			}
			return s;
		}
	}
}
