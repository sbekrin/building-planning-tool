part of planner;

/**
 * Line class is NOT used by Wall class
 */
class Line
{
	/*
	 * Data
	 */
	Point start;
	Point end;
	
	/*
	 * Constructor
	 */
	Line (this.start, this.end);
	
	/*
	 * Getters
	 */
	num get length => this.start.distanceTo(this.end);
	
	/**
	 * Checks if line intersect other
	 * Source: http://stackoverflow.com/questions/5514366/how-to-know-if-a-line-intersects-a-rectangle
	 */
	bool isIntersect (Line other)
	{
		double q = (this.start.y - other.start.y) * (other.end.x - other.start.x) - (this.start.x - other.start.x) * (other.end.y - other.start.y);
		double d = (this.end.x - this.start.x) * (other.end.y - other.start.y) - (this.end.y - this.start.y) * (other.end.x - other.start.x);
		
		if (d == 0)
		{
			return false;
		}
		
		double r = q / d;
		
		q = (this.start.y - other.start.y) * (this.end.x - this.start.x) - (this.start.x - other.start.x) * (this.end.y - this.start.y);
		
		double s = q / d;
		
		if (r < 0 || r > 1 || s < 0 || s > 1)
		{
			return false;
		}
		
		return true;
	}
}