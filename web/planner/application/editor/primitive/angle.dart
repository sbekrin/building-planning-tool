part of planner;

class Angle
{
	// Data
	double _degrees = 0.0;

	// Constructors
	Angle.fromDegrees (num degrees)
	{
		this._degrees = degrees.toDouble();
		
		this.reduce();
	}
	
	Angle.fromRadians (num radians)
	{
		this._degrees = Angle.rad2deg(radians.toDouble());
		
		this.reduce();
	}
	
	/*
	 * Converters
	 */
	num toDegrees ( ) => this._degrees;
	num toRadians ( ) => Angle.deg2rad(this._degrees);
		
	/**
	 * Converts angle to string format
	 */
	String toString ( ) => '${this._degrees}˚';
	
	/*
	 * Overloaded operators
	 */
	bool operator == (Object other)
	{
		if (other is Angle)
		{
			return this._degrees == other.toDegrees();
		}
		else if (other is num)
		{
			return this._degrees == other;
		}
		
		throw new Exception();
	}
	
	bool operator > (Object other)
	{
		if (other is Angle)
		{
			return this._degrees > other.toDegrees();
		}
		else if (other is num)
		{
			return this._degrees > other;
		}
		
		throw new Exception();
	}
	
	bool operator >= (Object other)
	{
		if (other is Angle)
		{
			return this._degrees >= other.toDegrees();
		}
		else if (other is num)
		{
			return this._degrees >= other;
		}
		
		throw new Exception();
	}
	
	bool operator < (Object other)
	{
		if (other is Angle)
		{
			return this._degrees < other.toDegrees();
		}
		else if (other is num)
		{
			return this._degrees < other;
		}
		
		throw new Exception();
	}
	
	bool operator <= (Object other)
	{
		if (other is Angle)
		{
			return this._degrees <= other.toDegrees();
		}
		else if (other is num)
		{
			return this._degrees <= other;
		}
		
		throw new Exception();
	}
	
	Object operator + (Object other)
	{
		if (other is Angle)
		{
			return new Angle.fromDegrees(this._degrees + other.toDegrees());
		}
		else if (other is num)
		{
			return this._degrees + other;
		}
		
		throw new Exception();
	}

	Object operator - (Object other)
	{
		if (other is Angle)
		{
			return new Angle.fromDegrees(this._degrees - other.toDegrees());
		}
		else if (other is num)
		{
			return this._degrees - other;
		}
		
		throw new Exception();
	}
	
	/**
	 * Converts radians to degrees
	 */
	static num rad2deg (num radians)
	{
		return radians * (180 / Math.PI);
	}
	
	/**
	 * Converts degrees to radians
	 */
	static num deg2rad (num degrees)
	{
		return degrees * (Math.PI / 180);
	}
	
	/**
	 * Reduce angle
	 */
	void reduce ( )
	{
		// If negative angle
		if (this._degrees < 0.0)
		{
			while (this._degrees < 0.0)
			{
				this._degrees += 360.0;
			}
		}
		
		// If positive
		else
		{
			while (this._degrees >= 360.0)
			{
				this._degrees -= 360.0;
			}
		}
	}
}