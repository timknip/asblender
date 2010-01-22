package com.floorplanner.blender.dna {

	/**
	 * @author timknip
	 */
	public class DNAField {
		
		/**
		 * 
		 */
		public var typeIndex:int;
		
		/**
		 * 
		 */
		public var nameIndex:int;
		
		/**
		 * 
		 */
		public var type:String;
		
		/**
		 * 
		 */
		public var name:String;
		
		/**
		 * 
		 */
		public var length:int;
		
		/**
		 * 
		 */
		public var arrayItems:Array;
		
		/**
		 * 
		 */
		public function DNAField(typeIndex:int=-1, nameIndex:int=-1) {
			this.typeIndex = typeIndex;
			this.nameIndex = nameIndex;	
			this.type = "";
			this.name = "";
			this.length = -1;
			this.arrayItems = new Array();
		}
		
		/**
		 * 
		 */		
		public function get numArrayItems():int {
			var num:int = 1;
			
			this.arrayItems = new Array();
			
			if (isArray) {
				var s:int = this.name.indexOf("[");
				var e:int = this.name.indexOf("]");
				if (s != -1 && e != -1) {
					num = parseInt(this.name.substr(s+1, e-s-1), 10);
					this.arrayItems.push(num);
					
					var t:String = this.name.substr(e + 1);
					s = t.indexOf("[");
					e = t.indexOf("]");
					if (s != -1 && e != -1) {
						var n:int = parseInt(t.substr(s+1, e-s-1), 10);
						num *= n;
						this.arrayItems.push(n);
					}
				}
			}
			
			return num;
		}
		
		/**
		 * 
		 */		
		public function get isArray():Boolean {
			return (this.name.indexOf("[") != -1 && this.name.indexOf("]") != -1);
		}
		
		/**
		 * 
		 */		
		public function get isCType():Boolean {
			return (
				this.type == "void" ||
				this.type == "char" ||
				this.type == "short" ||
				this.type == "int" || 
				this.type == "float" ||
				this.type == "double"
				);	
		}
		
		/**
		 * 
		 */		
		public function get isPointer():Boolean {
			return (this.name.charAt(0) == "*");
		}

		/**
		 * 
		 */
		public function get isSimpleType():Boolean {
			if (isPointer) return true;
			return isCType;
		}
		
		/**
		 * 
		 */		
		public function get shortName():String {
			var name:String = this.name;
			
			while (name.charAt(0) == "*") {
				name = name.substr(1);		
			}
			
			if (name.indexOf("[") != -1) {
				var parts:Array = name.split("[");
				name = parts[0];	
			}
			
			return name;
		}
	}
}
