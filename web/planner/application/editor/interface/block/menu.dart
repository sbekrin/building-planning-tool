part of planner;

/*
 * Menu class.
 *
 * Provides DOM wrapper and some handy tools.
 */
class Menu extends InterfaceBlock
{
	/*
	 * Defaults
	 */
	static const CLASS			= 'gui-menu',
				 VISIBLE_CLASS	= 'visible';
	
	/*
	 * Data
	 */
	Map<String, StreamSubscription>	_listeners	= new Map<String, StreamSubscription>();
	List<MenuShortcut>				_shortcuts	= new List<MenuShortcut>();
	List<MenuSection>				_sections	= new List<MenuSection>();
	
	/*
	 * Constructor
	 */
	Menu (List<MenuItem> items)
	{
		this._node = new Element.html('<menu class="$CLASS" type="toolbar"></menu>');
		
		this._compose();
		
		this._listeners['onMenuSectionSwitch']			= window.on[MenuSection.SWITCH_EVENT].listen(this._menuSectionSwitchHandler);
		this._listeners['onSpecialMenuSectionCreate']	= window.on[ContextMenuSection.CREATE_EVENT].listen(this._menuContextCreateHandler);
		this._listeners['onSpecialMenuSectionClose']	= window.on[ContextMenuSection.CLOSE_EVENT].listen(this._menuContextCloseHandler);
		
		this.registerAll(items);
	}
	
	/*
	 * Getters
	 */
	bool		get isExpanded				=> this._node.classes.contains(VISIBLE_CLASS);
	MenuSection	get _activeSection			=> this._sections.firstWhere((MenuSection section) => section.isActive, orElse: () => null);
	
	/**
	 * Handles menu section switch
	 */
	void _menuSectionSwitchHandler (CustomEvent event)
	{
		MenuSection section = this._sections.firstWhere((MenuSection section) =>
        															(section.hashCode == event.detail['section']));
        
        this.switchTo(section);
	}
	
	/**
	 * Handles special menu section creation
	 */
	void _menuContextCreateHandler (CustomEvent event)
	{
		ContextMenuSection section = event.detail['section'];
		
		this._cancelContextSections([ section.title ]);
		
		this.register(section);
		
		/*
		if (this.isExpanded)
		{
			this.switchTo(section);
		}
		*/
	}
	
	/**
	 * Handles special menu section close
	 */
	void _menuContextCloseHandler (CustomEvent event) => this._cancelContextSections(event.detail['ids']);
	
	/**
	 * Cancels all context sections
	 */
	void _cancelContextSections (List<String> ids)
	{
		this.unregisterAll(this._sections.where((MenuSection section) =>
															 ids.contains(section.title)).toList());
	}
	
	/**
	 * Hides menu
	 */
	void show ( )
	{
		this._node.classes.add(VISIBLE_CLASS);
	}
	
	/**
	 * Shows menu
	 */
	void hide ( )
	{
		this._node.classes.remove(VISIBLE_CLASS);
	}
	
	/**
	 * Switches to section tab
	 */
	void switchTo (MenuSection section)
	{
		bool wasActive = section.isActive;
		
		this._sections.forEach((MenuSection section) =>
                    						section.setInactive());
		
		// Hide menu
		if (wasActive)
		{
			this.hide();
		}
		
		// Switch to tab
		else
		{
			this.show();
			
            section.setActive();
		}
	}
	
	/**
	 * Registers single section
	 */
	void register (MenuItem item)
	{
		if (item is MenuShortcut)
		{
			this._shortcuts.add(item);
		}
		else if (item is MenuSection)
		{
			this._sections.add(item);
		}
		else
		{
			throw new Exception('Undefined menu item being registered');
		}
		
		this._node.children.add(item.node);
	}
	
	/**
	 * Registers bunch if sections
	 */
	void registerAll (List<MenuItem> items)
	{
		items.forEach((MenuItem section) =>
								this.register(section));
	}
	
	/**
	 * Unregisters single section
	 */
	void unregister (MenuItem item)
	{
		if (item is MenuShortcut)
		{
			this._shortcuts.remove(item);
		}
		else if (item is MenuSection)
		{
			this._sections.remove(item);
		}
		else
		{
			throw new Exception('Undefined menu item being unregistered');	
		}
		
		item.remove();
	}
	
	/**
	 * Unregisters bunch of context sections
	 */
	void unregisterAll (List/*<ContextMenuSection>*/ items)
	{
		this._sections.removeWhere((MenuSection section) =>
												items.contains(section));
		
		items.forEach((MenuSection section)
			{
				if (section.isActive)
				{
					this.hide();	
				}
				
				section.remove();
			}
		);
	}
}