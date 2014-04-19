package gameplay 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.TriangleCulling;
	import flash.geom.Matrix;
	import nape.geom.Mat23;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.space.Space;
	import utils.Interactions;
	import utils.Parser;
	/**
	 * Physical element, that is created according to it's type, has body, and different attributes
	 * @author Hammerzeit
	 */
	public class PhysicsElement 
	{
		private var _body:Body;
		private var _myType:String;
		
		private var _width:Number;
		private var _height:Number;
		
		private var _space:Space;
		
		public function PhysicsElement( type:String, levelObject:DisplayObjectContainer, space:Space, coordMatrix:Matrix=null, myCollisionGroup:int = 1, groupsToCollisdeWith:int = -1 ) 
		{
			_space = space;
			_myType = type;
			
			_body = createBody( levelObject, myCollisionGroup, groupsToCollisdeWith );
			
			_height = levelObject.getChildAt(0).height * levelObject.scaleY;
			_width = levelObject.getChildAt(0).width * levelObject.scaleX;			
			
			//Transform object according to given matrix
			if ( coordMatrix )
			{
				var tmp:Matrix = levelObject.transform.matrix.clone();
				tmp.concat(coordMatrix);
				levelObject.transform.matrix = tmp;		
			}
			
			var posX:Number = levelObject.x;
			var posY:Number = levelObject.y;
			
			_body.position.setxy(posX, posY);
			_body.rotation = levelObject.rotation / 180 * Math.PI;			
			
			_body.space = _space;
		}
		
		/**
		 * Physical body creation
		 * @param	levelObject
		 * @param	myCollisionGroup - power of two
		 * @param	groupsToCollisdeWith - int, 1's - groups to collide with
		 * @return
		 */
		private function createBody(levelObject:DisplayObjectContainer, myCollisionGroup:int, groupsToCollisdeWith:int):Body 
		{
			var body:Body;
			var sh:Shape;
			
			switch ( _myType )
			{				
				case Parser.OBJ_STATIC_CIRCLE:
					body = new Body( BodyType.STATIC );
					sh = new Circle(levelObject.getChildAt(0).width*levelObject.scaleX / 2);
					sh.filter.collisionGroup = myCollisionGroup;
					sh.filter.collisionMask = groupsToCollisdeWith;
					body.shapes.add( sh );					
					body.userData["type"] = "static" ;
					body.cbTypes.add( Interactions.instance.CBTYPE_STATIC_CIRCLE );
					break;
				case Parser.OBJ_STATIC_RECT:
					body = new Body( BodyType.STATIC );
					sh = new Polygon( Polygon.box(levelObject.getChildAt(0).width*levelObject.scaleX, levelObject.getChildAt(0).height*levelObject.scaleY) );
					sh.filter.collisionGroup = myCollisionGroup;
					sh.filter.collisionMask = groupsToCollisdeWith;
					body.shapes.add( sh );
					body.userData["type"] = "static" ;
					body.cbTypes.add( Interactions.instance.CBTYPE_STATIC_RECT );
					break;
				case Parser.OBJ_DYNAMIC_CIRCLE:
					body = new Body( BodyType.DYNAMIC );
					sh = new Circle(levelObject.getChildAt(0).width*levelObject.scaleX / 2);
					sh.material = Material.rubber();
					sh.filter.collisionGroup = myCollisionGroup;
					sh.filter.collisionMask = groupsToCollisdeWith;
					body.shapes.add( sh );
					body.userData["type"] = "dynamic" ;
					body.cbTypes.add( Interactions.instance.CBTYPE_DYNAMIC_CIRCLE );
					break;
				case Parser.OBJ_DYNAMIC_RECT:
					body = new Body( BodyType.DYNAMIC );
					sh = new Polygon( Polygon.box(levelObject.getChildAt(0).width*levelObject.scaleX, levelObject.getChildAt(0).height*levelObject.scaleY) );	
					sh.filter.collisionGroup = myCollisionGroup;
					sh.filter.collisionMask = groupsToCollisdeWith;
					body.shapes.add(sh);
					body.userData["type"] = "dynamic" ;
					body.cbTypes.add( Interactions.instance.CBTYPE_DYNAMIC_RECT );
					break;				
			}
			return body;
		}
		
		/**
		 * Adds shape to already existing body
		 * @param	levelObject
		 * @param	myCollisionGroup - power of two
		 * @param	groupsToCollisdeWith - int, 1's - groups to collide with
		 */
		public function addShapeToBody(levelObject:DisplayObjectContainer, myCollisionGroup:int = 1, groupsToCollisdeWith:int = -1):void 
		{
			var sh:Shape;
			
			switch ( Parser.getClassName(levelObject) )
			{
				case Parser.OBJ_DYNAMIC_CIRCLE:
					sh = new Circle(levelObject.getChildAt(0).width*levelObject.scaleX / 2);
					sh.material = Material.rubber();
					sh.filter.collisionGroup = myCollisionGroup;
					sh.filter.collisionMask = groupsToCollisdeWith;
					
					sh.rotate( levelObject.rotation * Math.PI / 180 );
					sh.translate( Vec2.get( levelObject.x, levelObject.y, true ) );
					
					_body.shapes.add( sh );					
					break;
				case Parser.OBJ_DYNAMIC_RECT:
					var points:Array = Polygon.box(levelObject.getChildAt(0).width * levelObject.scaleX, levelObject.getChildAt(0).height * levelObject.scaleY);
					sh = new Polygon( points );	
					sh.filter.collisionGroup = myCollisionGroup;
					sh.filter.collisionMask = groupsToCollisdeWith;
					
					sh.rotate( levelObject.rotation * Math.PI / 180 );
					sh.translate( Vec2.get( levelObject.x, levelObject.y, true ) );
					
					_body.shapes.add(sh);
					break;				
			}
		}
		
		public function get body():Body 
		{
			return _body;
		}
		
		public function get myType():String 
		{
			return _myType;
		}
		
		public function get height():Number 
		{
			return _height;
		}
		
		public function get width():Number 
		{
			return _width;
		}
		
		public function get space():Space 
		{
			return _space;
		}
		
	}

}