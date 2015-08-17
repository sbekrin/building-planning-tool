part of planner;

/**
 *	Settings class provides easy-to-set stuff
 */
class Settings
{
	/*
	 * Data
	 */
	static Map<String, Object> _data = new Map<String, Object>();
	
	/*
	 * Constructor
	 */
	Settings ( )
	{
		// Set defaults
		set('anchor-snap',				true);
		set('wall-snap',				true);
		set('grid-snap',				false);
		set('max-history-snapshots',	30);
	}
	
	/**
	 * Creates setting data
	 */
	static void set (String key, Object value)
	{
		Settings._data[key] = value;
	}
	
	/**
	 * Toggles setting data
	 */
	static void toggle (String key)
	{
		if (Settings._data[key] is! bool)
		{
			throw new Exception('Attemp to toggle non-boolean value');
		}
		
		Settings.set(key, !Settings.get(key));
	}
	
	/**
	 * Reads setting data
	 */
	static Object get (String key)
	{
		return Settings._data[key];
	}
	
	/**
	 * Deletes setting data
	 */
	static void delete (String key)
	{
		Settings._data.remove(key);
	}
}