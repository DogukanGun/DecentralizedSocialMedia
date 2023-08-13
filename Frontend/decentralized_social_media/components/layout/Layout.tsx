import React, { ReactNode } from 'react';
import CustomNavbar from "../navbar/Navbar";

interface LayoutProps {
    children: ReactNode;
}
const Layout: React.FC<LayoutProps> = ({ children }) =>
    <main>
        <CustomNavbar/>
        {children}
    </main>

export default Layout;