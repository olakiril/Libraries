classdef Queue < handle
% Queue define a queue data strcuture
% 
%   q = Queue;
%   s.size() return the numble of element
%   s.isempty() return true when the queue is empty
%   s.empty() delete all the elements in the queue.
%   s.push(el) push elelemnt to the top of qeueu
%   s.pop() pop out the element at the beginning of queue, and return the element
%   s.content() return all the data of the queue (in the form of a
%   cells with size [s.size(), 1]

    properties (Access = private)
        buffer      % a cell, to maintain the data
    end
    
    methods
        function obj = Queue 
            obj.buffer = [];
        end
        
        function s = size(obj) 
            s = length(obj.buffer);
        end
        
        function b = isempty(obj)   % return true when the queue is empty
            b = ~logical(obj.size());
        end
        
        function s = empty(obj) % clear all the data in the queue
            s = obj.size();
            obj.buffer = [];
        end
        
        function push(obj, el) % 
            obj.buffer{end+1} = el;
        end
        
        function pushFront(obj, el) %
            s = obj.size;
            obj.buffer(2:s+1) = obj.buffer;
            obj.buffer{1} = el;
        end
        
        function el = pop(obj,index) 
            if obj.size()
                if ~exist('index','var')
                    el = obj.buffer{1};
                    obj.buffer = obj.buffer(2:end);
                else
                    el = obj.buffer(index);
                    obj.buffer(index) = [];
                end
            else
                el = [];
            end             
        end
        
        function el = peek(obj,index) 
            if obj.size()
                if  ~exist('index','var')
                    el = obj.buffer{1};
                else
                    el = obj.buffer(index);
                end
            else
                el = [];
            end             
        end
        
        function display(obj) 
            sz = obj.size();
            if sz
                for i = 1:sz
                    disp([num2str(i) '-th element of the stack:']);
                    disp(obj.buffer{i});
                end
            else
                disp('The queue is empty');
            end
        end
        
        function c = content(obj) 
                c = obj.buffer(:);                    
        end
    end
end