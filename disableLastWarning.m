function disableLastWarning
w = warning('query','last');
id = w.identifier;
warning('off',id)