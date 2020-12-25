/*
	Copyright (c) 2006, 2007 Nicholas Bilyk
*/

package utils {
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import utils.CoordMath;
	
	public class PivotRotate {
		public var root_mc:DisplayObject;
		public var pivotPoint:Point;
	
		function PivotRotate(root:DisplayObject, p:Point) {
			root_mc = root;
			pivotPoint = p.clone();
		}
		public function set rotation(r:Number):void {
			// Rotates root_mc r degrees around pivotPoint.
			var originalPoint:Point = pivotPoint.clone();
			originalPoint = CoordMath.convertCoords(originalPoint, root_mc, root_mc.parent);
			root_mc.rotation = r;
			var rotatedPoint:Point = pivotPoint.clone();
			rotatedPoint = CoordMath.convertCoords(rotatedPoint, root_mc, root_mc.parent);
			root_mc.x += (originalPoint.x - rotatedPoint.x);
			root_mc.y += (originalPoint.y - rotatedPoint.y);
		}
		public function get rotation():Number {
			return root_mc.rotation;
		}
	}
}