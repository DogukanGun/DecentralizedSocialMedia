import { Session } from 'inspector';
import '../styles/globals.css'
import { AppProps } from 'next/app';
import Layout from '@/components/layout/Layout';

const MyApp = ({
  Component,
  pageProps
}: AppProps<{
  initialSession: Session
}>) => {
  return (
    <Layout>
      <Component {...pageProps} />
    </Layout>
  );
}
export default MyApp;