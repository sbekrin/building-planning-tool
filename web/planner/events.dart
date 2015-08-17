part of planner;

/**
 *	Content Selection event triggers each time canvas object
 *	being selected 
 */
class ContentSelectionEvent
{
	ContentSelectionEvent (Rectangle area)
	{
		window.dispatchEvent(new CustomEvent(Selection.SELECT_EVENT, detail: { 'area': area }));
	}
}