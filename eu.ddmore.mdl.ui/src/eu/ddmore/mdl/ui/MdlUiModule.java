/*
 * generated by Xtext
 */
package eu.ddmore.mdl.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.resource.containers.IAllContainersState;
import org.eclipse.xtext.ui.editor.autoedit.DefaultAutoEditStrategyProvider;
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultSemanticHighlightingCalculator;
import org.eclipse.xtext.ui.wizard.IProjectCreator;

import com.google.inject.Binder;
import com.google.inject.Provider;
import com.google.inject.Singleton;

import eu.ddmore.mdl.ui.wizard.NonJDTProjectCreator;

/**
 * Use this class to register components to be used within the IDE.
 */
public class MdlUiModule extends eu.ddmore.mdl.ui.AbstractMdlUiModule {

//    private static final Logger LOG = Logger.getLogger(MdlUiModule.class);
//
//    private static final String MIF_ENCRYPTION_KEY = "mif.encryption.key";

    public MdlUiModule(AbstractUIPlugin plugin) {
        super(plugin);
//        init();
    }
    
//    @Override
//    public Class<? extends IResourceForEditorInputFactory> bindIResourceForEditorInputFactory(){
//    	return ResourceForIEditorInputFactory.class;
//    }
    
    
//    @Override
//    public Class<? extends IResourceSetProvider> bindIResourceSetProvider(){
//    	return SimpleResourceSetProvider.class;
//    }
    
    @Override
    public Class<? extends IProjectCreator> bindIProjectCreator(){
    	return NonJDTProjectCreator.class;
    }
    
    @Override
    public Provider<IAllContainersState> provideIAllContainersState(){
    	return org.eclipse.xtext.ui.shared.Access.getWorkspaceProjectsState();
    }
    
    @Override
    public void configure(Binder binder) {
        super.configure(binder);
//        binder.bind(IOutputConfigurationProvider.class).to(MDLOutputConfigurationProvider.class).in(Singleton.class);
        binder.bind(DefaultAutoEditStrategyProvider.class).to(MDLAutoEditStartegyProvider.class).in(Singleton.class);
        binder.bind(DefaultSemanticHighlightingCalculator.class).to(MdlSemanticHighlightingCalculator.class);
    }

//    public void init() {
//        if (System.getProperty(MIF_ENCRYPTION_KEY) != null) {
//            try {
//                // FIXME expecting MIF_ENCRYPTION_KEY to contain the path relative to the CWD
//                URL url = new URL("file:/" + System.getProperty("user.dir") + "/" + System.getProperty(MIF_ENCRYPTION_KEY));
//                LOG.debug(String.format("%s property was set to %s", MIF_ENCRYPTION_KEY, url));
//                System.setProperty(MIF_ENCRYPTION_KEY, url.toExternalForm());
//            } catch (MalformedURLException e) {
//                LOG.error(String.format("%s property was set to and invalid URL", MIF_ENCRYPTION_KEY), e);
//            }
//        } else {
//            LOG.warn(String.format("%s property was not set", MIF_ENCRYPTION_KEY));
//        }
//    }
}
