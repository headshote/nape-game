package gameplay 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	import levels.common.Game;
	import nape.constraint.DistanceJoint;
	import nape.constraint.LineJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Circle;
	import nape.space.Space;
	import utils.Parser;
	
	/**
	 * Actor class - contains vehicle with shock absorbers
	 * @author Hammerzeit
	 */
	
	public class Actor 
	{
		private var _wheels:Array;
		private var _wheelShockAngles:Array;
		private var _hull:PhysicsElement;
		
		private var _lineJoints:Vector.<LineJoint>;
		private var _distanceJoints:Vector.<DistanceJoint>;
		
		private var _game:Game;
		
		private var _jumpPressed:Boolean = false;	
		
		private var _space:Space;
		
		public var constraintDamper:Number;
		public var heightDamper:Number;
		public var distanceChassisPivot:Number;
		
		public var damper:Number;
		public var frequency:Number;
		
		
		public function Actor( src:DisplayObjectContainer, space:Space, game:Game ) 
		{
			_space = space;
			
			_wheels = new Array();
			_wheelShockAngles = new Array();
			
			_game = game;
			
			var len:int = src.numChildren;
			var part:DisplayObject;
			for ( var i:int = 0; i < len; i++ )
			{
				part = src.getChildAt(i);
				
				if ( Parser.getClassName(part) == Parser.OBJ_DYNAMIC_CIRCLE )
				{
					_wheels.push( new PhysicsElement( Parser.getClassName(part), part as DisplayObjectContainer, space, src.transform.matrix ) );
					//Angle of shock absorber of this wheel is read from it's name property, e.g.: ang_90, ang_1, ang_135
					_wheelShockAngles.push( Parser.readShockAngle( part.name) );
					_wheels[_wheels.length - 1].body.userData["type"] = "actor" ;
				}				
				else if ( Parser.getClassName(part) == Parser.OBJ_DYNAMIC_RECT )
				{
					if ( !_hull )
					{
						_hull = new PhysicsElement( Parser.getClassName(part), part as DisplayObjectContainer, space, src.transform.matrix );
						_hull.body.userData["type"] = "actor" ;
					}
					else
					{
						_hull.addShapeToBody( part as DisplayObjectContainer );
					}
				}
			}
			
			linkCarToWheels();			
		}
		
		/**
		 * Should be called every frame
		 */
		public function update():void
		{			
			if ( _game.keyIsPressed( Keyboard.W ) )
			{
				motor(25);
			}
			else if ( _game.keyIsPressed( Keyboard.S ) )
			{
				motor(-25);
			}
			else
			{
				motor(0);
			}
			
			if ( _game.keyIsPressed( Keyboard.A ) )
			{
				tilt(-1);
			}
			else if ( _game.keyIsPressed( Keyboard.D ) )
			{
				tilt(1);
			}
			else
			{
				tilt(0);
			}
			
			if ( _game.keyIsPressed( Keyboard.SPACE ) )
			{
				if ( !_jumpPressed &&  !inAir() )
				{
					jump(0, -1500);
					_jumpPressed = true;
				}
			}
			else
			{
				_jumpPressed = false;
			}
		}	
		
		/**
		 * Attaches wheelt to hull, with two joints - lineJoint, non-stiff, moves over the line in set direction;
		 * distanceJoint - stiff - acts like sprint, trying to brint back the translated linejoint into it's max
		 * position, after it has been 'squeezed' by some force
		 */
		protected function linkCarToWheels():void
		{			
			heightDamper = 20;
			constraintDamper = heightDamper + 5;
			
			var hullBottom:Number = _hull.body.position.y + _hull.height / 2;			
			
			damper = 0.005;
			frequency = 2.5;
			
			_distanceJoints = new Vector.<DistanceJoint>();
			_lineJoints = new Vector.<LineJoint>();
			
			for ( var i:int = 0; i < _wheels.length; i++ )
			{
				var wheelPivot:Number = _wheels[i].body.position.y;
				distanceChassisPivot = Math.abs( hullBottom - wheelPivot );
				
				//Angle of shock absorber
				var shockAngle:Number = _wheelShockAngles[i];
				var tangA:Number = Math.tan( shockAngle * Math.PI / 180 );
				var m:Number = 1.0;
				var l:Number = m / tangA;
				
				//Both joints allow their connected bodies to rotate
				//Line joint, where second body moves on a line defined by point anchor1 and directional vector, is NOT stiff
				_lineJoints.push( new LineJoint(_hull.body, _wheels[i].body, 
											new Vec2(_hull.body.worldPointToLocal(_wheels[i].body.position).x, distanceChassisPivot), new Vec2(0, 0), 
											new Vec2(l, m), distanceChassisPivot, distanceChassisPivot + heightDamper) );
				_lineJoints[_lineJoints.length-1].ignore = true;
				_lineJoints[_lineJoints.length-1].stiff = true;
				_lineJoints[_lineJoints.length - 1].space = _space;
				
				//Distance joint - spring, that returns to it's orig. position after squeezing, is stiff
				_distanceJoints.push( new DistanceJoint(_hull.body, _wheels[i].body, 
												new Vec2(_hull.body.worldPointToLocal(_wheels[i].body.position).x, distanceChassisPivot), new Vec2(0, 0),
												distanceChassisPivot + heightDamper, distanceChassisPivot + constraintDamper) );
				_distanceJoints[_distanceJoints.length-1].stiff = false;
				_distanceJoints[_distanceJoints.length-1].frequency = frequency;
				_distanceJoints[_distanceJoints.length - 1].damping = damper;
				_distanceJoints[_distanceJoints.length - 1].space = _space;				
			}
		}		
		
		/**
		 * Activating rotation of the wheels with some speed
		 * @param	speed
		 */
		public function motor( speed:Number ):void 
		{
			for ( var i:String in _wheels )
				_wheels[i].body.angularVel = speed;
		}
		
		/**
		 * tilts car to the side
		 * @param	direction
		 */
		public function tilt( direction:int ):void 
		{
			//_hull.body.applyAngularImpulse( direction * 10000 );
			_hull.body.torque = direction * 120000;
			//_hull.body.angularVel = direction * 10;
		}
		
		/**
		 * jump, x and y define direction vector of an impulse
		 * @param	x
		 * @param	y
		 */
		public function jump(x:Number, y:Number):void 
		{
			var vec:Vec2 = Vec2.get(x, y);
			
			_hull.body.applyImpulse(vec);
			
			for ( var i:String in _wheels )
				_wheels[i].body.applyImpulse(vec);
				
			vec.dispose();
		}
		
		/**
		 * Return true if car isn't standing on solid surface
		 * @return
		 */
		public function inAir():Boolean 
		{
			//if (  _space.bodiesInBody( _hull.body ).length == 0 ) 
				//return true;
			//
			//for ( var i:int = 0; i < _wheels.length; i++ )
			//{
				//if (  _space.bodiesInBody( _wheels[i].body ).length == 0 ) 
					//return true;
			//}
			//
			//return false;
			
			if ( _hull.body.arbiters.length > 0 )
				return false;
			
			for ( var i:int = 0; i < _wheels.length; i++ )
			{
				if (_wheels[i].body.arbiters.length > 0 )
					return false
			}
			
			return true;
			
			//if ( !_hull.body.userData["inAir"] )
				//return false
			//
			//for ( var i:int = 0; i < _wheels.length; i++ )
			//{
				//if (_wheels[i].body.userData["inAir"] )
					//return true
			//}
			//
			//return false;
		}
		
		public function getPos():Vec2 
		{
			return _hull.body.position;
		}		
		
	}

}