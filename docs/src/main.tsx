import { ViteReactSSG } from 'vite-react-ssg/single-page';
import App from './App';
import { PageProvider } from './PageContext';
import './style.css';

export const createRoot = ViteReactSSG(
  <PageProvider>
    <App />
  </PageProvider>,
);
