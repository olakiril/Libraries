function renderedFigure

a = get(gcf,'RendererMode');

if strcmp(a,'auto')
        set(gcf,'RendererMode','manual')
        set(gcf,'Renderer','OpenGL')
end