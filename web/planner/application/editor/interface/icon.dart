part of planner;

/*
 *	Icon class.
 *
 *	Simple wrapper for DOM element. Id's should be
 *	'like-this-form'.
 */
class Icon
{
	/*
	 * Defaults
	 */
	static const CLASS			= 'gui-icon',
				 UNQIE_PREFIX	= 'gui-icon-';
	
	/*
	 * Data
	 */
	static final Map<String, Icon> _icons = new Map<String, Icon>();
	final SpanElement node = new SpanElement();
	final String iconId;
	
	/*
	 * Factory
	 */
	factory Icon (String iconId)
	{
		if (Icon._icons.containsKey(iconId))
		{
			return Icon._icons[iconId];
		}
		else
		{
			final Icon icon = new Icon._internal(iconId);
			
			Icon._icons[iconId] = icon;
			
			return icon;
		}
	}
	
	/*
	 * Constructor
	 */
	Icon._internal (this.iconId)
	{
		this.node.classes.addAll([ CLASS, '$UNQIE_PREFIX$iconId' ]);
	}
	
	/*
	 * Converts icon to html
	 */
	String toString ( )
	{
		// Cap for empty icon
		if (this.iconId == '')
		{
			return '';
		}
		
		String tag = this.node.toString();
		List<String> classes = new List<String>();
		
		this.node.classes.forEach((String classname) =>
										  classes.add(classname));
		
		return '<$tag class="${classes.join(' ')}"></$tag>';
	}
}