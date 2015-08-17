part of planner;

/*
 *	Menu Section class.
 *
 *	Provides DOM wrapper and some basic tools for
 *	section manipulation.
 */
class MenuSection extends MenuItem
{
	/*
	 * Defaults
	 */
	static const CLASS					= 'gui-menu-section',
				 ACTIVE_CLASS			= 'expanded',
				 TITLE_CLASS			= 'gui-menu-section-title',
				 CONTENT_CLASS			= 'gui-menu-section-content',
				 
				 // Events
				 SWITCH_EVENT			= 'onMenuSectionSwitch';

	/*
	 * Data
	 */
	Map<String, StreamSubscription>	_listeners	= new Map<String, StreamSubscription>();
	List<MenuSectionGroup>			_groups		= new List<MenuSectionGroup>();

	/*
	 * Constructor
	 */
	MenuSection (String title, [ List<MenuSectionGroup> groups ])
	{
		this._node = new Element.html('''
			<li class="$CLASS">
				<a class="$TITLE_CLASS">$title</a>
				<ul class="$CONTENT_CLASS"></ul>
			</li>
		''');
		
		this._listeners['onMouseDown']	= this._titleNode.on['mousedown'].listen(this._inputDeviceDownHandler);
		this._listeners['onTouchStart']	= this._titleNode.on['touchstart'].listen(this._inputDeviceDownHandler);
		
		this._compose();
		
		this.registerAll(groups);
	}
	
	/*
	 * Getters
	 */
	Element	get _titleNode		=> this._node.querySelector('.$TITLE_CLASS');
	Element	get _contentNode	=> this._node.querySelector('.$CONTENT_CLASS');
	String	get title			=> this._titleNode.text;
	bool	get isActive		=> this._node.classes.contains(ACTIVE_CLASS);
	bool	get isNotActive		=> !this.isActive;
	
	/*
	 * Setters
	 */
	set	title (String value) => this._titleNode.text = value;
	
	/**
	 * Handles touchstart
	 */
	void _inputDeviceDownHandler (Event event)
	{
		window.dispatchEvent(new CustomEvent(SWITCH_EVENT, detail: { 'section': this.hashCode }));
        
		event.preventDefault();
		event.stopPropagation();
	}
	
	/**
	 * Sets section as active
	 */
	void setActive ( )
	{
		this._node.classes.add(ACTIVE_CLASS);
	}
	
	/**
	 * Sets section as inactive
	 */
	void setInactive ( )
	{
		this._node.classes.remove(ACTIVE_CLASS);
	}
	
	/**
	 * Registers group element
	 */
	void register (MenuSectionGroup group)
	{
		this._groups.add(group);
		this._contentNode.children.add(group.node);
	}
	
	/**
	 * Registers group element
	 */
	void registerAll (List<MenuSectionGroup> groups)
	{
		groups.forEach((MenuSectionGroup group) =>
										 this.register(group));
	}
}