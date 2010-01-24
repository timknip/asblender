package com.floorplanner.blender.dna {

	import flash.utils.ByteArray;
	
	/**
	 * @author timknip
	 */
	public class DNAFieldInstance {
		
		/**
		 * 
		 */
		public var field:DNAField;
		
		/**
		 * 
		 */
		public var pointerSize:int;
		
		/**
		 * Constructor.
		 * 
		 * @param field
		 */
		public function DNAFieldInstance(field:DNAField, pointerSize:int=4) {
			this.field = field;
			this.pointerSize = pointerSize;
		}

		/**
		 * 
		 */
		public function read(data:ByteArray):Array {
			var result:Array = new Array();
			var num:int = this.field.numArrayItems;
			var i:int;
			
			for (i = 0; i < num; i++) {
				if (this.field.isPointer) {
					result.push(data.readInt());
					if (pointerSize > 4) {
						result.push(data.readInt());
					}
				} else if (this.field.isSimpleType) {
					switch (this.field.type) {
						case "void":
							break;
						case "char":
							result.push(data.readUnsignedByte());
							break;
						case "short":
							result.push(data.readUnsignedShort());
							break;
						case "int":
							result.push(data.readInt());
							break;
						case "float":
							result.push(data.readFloat());
							break;
						case "double":
							result.push(data.readDouble());
							break;
						default:
							break;
					}
				}
			}
			return result;
		}
	}
}
