const Hero = () =>{
    return(
        <section className="flex flex-col items-center">
            <div className="flex max-w-xl flex-col items-center pb-16 pt-8 text-center lg:pb-48 lg:pt-32">
            <p className="mb-4 font-semibold text-indigo-500 md:mb-6 md:text-lg xl:text-xl">Very proud to introduce</p>

            <h1 className="mb-8 text-4xl font-bold text-black sm:text-5xl md:mb-12 md:text-6xl">Revolutionary way to build the web</h1>

            <div className="flex w-full flex-col gap-2.5 sm:flex-row sm:justify-center">
                <a href="#" className="inline-block rounded-lg bg-indigo-500 px-8 py-3 text-center text-sm font-semibold text-white outline-none ring-indigo-300 transition duration-100 hover:bg-indigo-600 focus-visible:ring active:bg-indigo-700 md:text-base">Start now</a>

                <a href="#" className="inline-block rounded-lg bg-gray-200 px-8 py-3 text-center text-sm font-semibold text-gray-500 outline-none ring-indigo-300 transition duration-100 hover:bg-gray-300 focus-visible:ring active:text-gray-700 md:text-base">Take tour</a>
            </div>
            </div>
        </section>
    )
}
export default Hero;