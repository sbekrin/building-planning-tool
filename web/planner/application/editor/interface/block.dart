part of planner;

/*
 *	Interface Block class.
 *
 *	This is base class for any custom GUI block.
 *	TODO: Would be great to rewrite via Polymer.dart
 */
abstract class InterfaceBlock
{
	/*
	 * Defaluts
	 */
	static const CLASS = 'gui-block';

	/*
	 * Data
	 */
	Element _node;
	
	/**
	 * Composes block
	 */
	void _compose ( )
	{
		this._node.classes.add(CLASS);
	}
	
	/*
	 * Getters
	 */
	Element get node => this._node;
	
	/**
	 * Removes node
	 */
	void removeNode ( )
	{
		this._node.remove();
	}
}