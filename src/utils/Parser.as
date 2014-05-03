package utils 
{
	import flash.display.*;
	import flash.utils.*;
	/**
	 * Parses some display object's class names, instance names, etc., gives useful info based on that
	 * @author Hammerzeit
	 */
	public class Parser 
	{	
		public static const OBJ_DYNAMIC_CIRCLE:String = "Obj_DynamicCircle";
		public static const OBJ_STATIC_CIRCLE:String = "Obj_StaticCircle";
		public static const OBJ_DYNAMIC_RECT:String = "Obj_DynamicRect";
		public static const OBJ_STATIC_RECT:String = "Obj_StaticRect";
		
		public static const JOINT_PIVOT:String = "Joint_Pivot";
		
		public static const TYPE_OBJECT:String = "Object";
		public static const TYPE_ACTOR:String = "Actor";
		public static const TYPE_JOINT:String = "Joint";		
		public static const TYPE_NONE:String = "None";
		
		/**
		 * Parse name of physics object and read collision group and mask of it.
		 * Group is an integer, power of two - 2, 4, 8, 16, 32, 64.
		 * Mask - a buch of such numbers, group, with which collision of our body will be performed.
		 * @param	name - e.g.: group_2_mask_2_4_8_16_32_64_128, group_2
		 * @return
		 */
		public static function parsePhysicsObjName(name:String):Array 
		{
			var ret:Array;			
			var nameSplit:Array = name.split("_");
			
			if ( nameSplit.length > 3 )
			{
				var mask:int = 0;
				
				ret = new Array();
				ret.push( int( nameSplit[1] ) );
				
				for ( var i:int = 3; i < nameSplit.length; i++ )
				{
					mask |=  int(nameSplit[i]);
				}
				ret.push( mask );
			}
			else if ( nameSplit.length == 2 )
			{
				ret = new Array();
				ret.push( int( nameSplit[1] ) );
				ret.push( -1 );
			}
			
			return ret;
		}
		
		/**
		 * reads name of the joint marker from level sprite in fla file, e.g. : pos_1 = 1, neg_2 = -2, no name - 0
		 * this will be the rate of motor joint
		 * @param	name
		 * @return
		 */
		public static function parseJointName(name:String):Number 
		{
			return ( name.split("_").length > 1 ? ( ( name.split("_")[0] == "neg" ? -1 : 1 ) * Number(name.split("_")[1]) ) : 0 );
		}
		
		public static function getClassName(obj:Object):String
		{
			return getQualifiedClassName(obj);
		}
		
		static public function getClassType(levelObject:DisplayObject):String 
		{
			switch ( getClassName(levelObject).split("_")[0] )
			{
				case "Obj":
					return TYPE_OBJECT; 
				case "Actor":
					return TYPE_ACTOR;
				case "Joint":
					return TYPE_JOINT;
			}
			return TYPE_NONE;
		}
		
		/**
		 * 
		 * @param	name, e.g.: ang_90, ang_1, ang_45, ang_135, if no name - 90 will be the value
		 * @return
		 */
		static public function readShockAngle(name:String):Number 
		{
			var splitName:Array = name.split("_");
			if ( splitName.length > 1 )
			{
				if ( splitName[0] == "ang" )
				{
					return Number(splitName[1]);
				}
			}
			return 90.0;
		}
		
	}

}