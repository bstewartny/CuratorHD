function highlightText(color,className,text)
{
	text=text.toLowerCase();
	
	var el=document.getElementById('readability-content');
	
	if(el)
	{
		highlightNodes(el,color,className,text);
	}
}

function highlightNodes(node,color,className,text)
{
	if (node.nextSibling)
	{
		highlightNodes(node.nextSibling,color,className,text);
	}
	
	if (node.nodeType == 8) 
	{
		return; //Don't update comments
	}
	
	if (node.firstChild)
	{
		highlightNodes(node.firstChild,color,className,text);
	}
	
	if(node.nodeType==3) // text node
	{
		if (node.nodeValue) 
		{ // update me    
			
			var nv=node.nodeValue;
			var lc=nv.toLowerCase();
			
			var start=lc.indexOf(text);
			
			if(start>-1)
			{
				var span=document.createElement("span");
				var newHTML='';
				var last_part=nv;
				var last_part_lc=last_part.toLowerCase();
				
				while((start=last_part_lc.indexOf(text))>-1)
				{
					  var first_part=last_part.substring(0,start);
					  var match_part=last_part.substring(start,start+text.length);
				
					  last_part=last_part.substring(start+text.length);
					  last_part_lc=last_part.toLowerCase();
					  
					  newHTML+=first_part;
					  newHTML+='<span style="background-color:'+color+'" class="'+className+'">';
					  newHTML+=match_part;
					  newHTML+='</span>';
				}
				newHTML+=last_part;
				span.innerHTML=newHTML;
				node.parentNode.insertBefore(span,node);
				node.parentNode.removeChild(node);
			}
		} 
	}
}
