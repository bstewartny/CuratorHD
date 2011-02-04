
if(!curatorHDToolsLoaded)
{
	curatorHDGetHTMLElementsAtPoint=function(x,y) 
	{
		var tags = ",";
		var e = document.elementFromPoint(x,y);
		while (e) 
		{
			if (e.tagName) 
			{
				tags += e.tagName + ',';
			}
			e = e.parentNode;
		}
		return tags;
	};

	curatorHrefAtPoint=function(x,y)
	{
		var e=document.elementFromPoint(x,y);
		while(e)
		{
			if(e.tagName=='A')
			{
				if(e.hasAttribute('href'))
				{
					return e.getAttribute('href');
				}
			}
			e = e.parentNode;
		}
		return '';
	};

	curatorImgSrcAtPoint=function(x,y)
	{
		var e=document.elementFromPoint(x,y);
		while(e)
		{
			if(e.tagName=='IMG')
			{
				if(e.hasAttribute('src'))
				{
					return e.getAttribute('src');
				}
			}
			e = e.parentNode;
		}
		return '';
	};

	curatorTitleAtPoint=function(x,y)
	{
		var e=document.elementFromPoint(x,y);
		while(e)
		{
			if(e.tagName=='IMG')
			{
				if(e.hasAttribute('title'))
				{
					return e.getAttribute('title');
				}
				if(e.hasAttribute('alt'))
				{
					return e.getAttribute('alt');
				}
			}
			if(e.tagName=='A')
			{
				if(e.hasAttribute('title'))
				{
					return e.getAttribute('title');
				}
				if(e.textContent)
				{
					return e.textContent;
				}
			}
			e = e.parentNode;
		}
		return '';
	};

	var curatorHDToolsLoaded='yes';

}