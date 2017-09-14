import React from 'react';
import PropTypes from 'prop-types';
import { render} from 'react-dom';
import { WdkStore } from 'wdk-client/Stores';

// An adaptor that allows us to reuse react client components on the legacy website.
// This currently only works with components that are not view-specific
// (like the header and footer).


class ClientContextProvider extends React.Component {

  getChildContext() {
    // get store
    const { stores, dispatchAction } = window.ebrc.context;
    const store = stores.get(WdkStore);
    return { store, dispatchAction }
  }

  render() {
    return this.props.children;
  }

}

ClientContextProvider.childContextTypes = {
  store: PropTypes.instanceOf(WdkStore).isRequired,
  dispatchAction: PropTypes.func.isRequired
}


export function renderWithContext(reactElement, container) {
  render((
    <ClientContextProvider>
      {reactElement}
    </ClientContextProvider>
  ), container);
}
